"""Communicate with NFC devices using libnfc on the I2C bus.

This class does not implement the full libnfc library; I
only included the functions that I needed.

Example:
    The following will open the device, wait for a tag,
    and then wait until the tag is removed.

    # open the nfc device
    reader = Nfci2c('pn532_i2c:/dev/i2c-1')

    # read a tag
    tag = reader.getTag()
    while tag is None:
        tag = reader.getTag()

    print('Found tag: '), tag

    # wait until tag is removed
    while reader.isTagPresent():
        pass
    print('Tag was removed')

Notes:
    This was built using Cython

Author:
    Mac Baker (bakerjm24450.dev@gmail.com)
"""

cimport src.cnfci2c as cnfci2c

from cpython cimport array
import array

import smbus as smbus
import time

cdef class Nfci2c:
    """Interface for a pn532-based NFC chip

    Attributes:
        __context (nfc_context*): Handle for the libnfc library
        __device (nfc_device*): NFC device (i.e., pn532 chip)
        __target (nfc_target): NFC tag
    """
    cdef cnfci2c.nfc_context* __context
    cdef cnfci2c.nfc_device* __device
    cdef cnfci2c.nfc_target __target


    def __cinit__(self, bytes connstring):
        """Initialize the NFC device as an initiator
       
        Args:
            connstring (string): Optional connection string for location
            of pn532 device (ex. 'pn532_i2c:/dev/i2c-1'). If None, then
            first located device is used

        """
        # wake up the NFC chip
        self._wakeup(connstring)

        # init the library
        cnfci2c.nfc_init(&self.__context)
        if self.__context is NULL:
            raise MemoryError("Unable to initialize NFC library")

        # do we have a connection string?
        cdef char* cs = NULL 
        if connstring:
            cs = connstring

        # open the device
        self.__device = cnfci2c.nfc_open(self.__context, cs)
        if self.__device is NULL:
            # cnfci2c.nfc_exit(self.__context)
            raise IOError("Unable to open NFC device")

        # set as NFC initiator
        cdef int result = cnfci2c.nfc_initiator_init(self.__device)
        if result < 0:
            # cnfci2c.nfc_close(self.__device)
            # cnfci2c.nfc_exit(self.__context)
            raise IOError("Unable to open NFC device")

    def __dealloc__(self):
        """Close the NFC device"""
        if self.__device is not NULL:
            cnfci2c.nfc_close(self.__device)
        if self.__context is not NULL:
            cnfci2c.nfc_exit(self.__context)

    cpdef object getTag(self):
        """Reads an NFC tag.

        Notes: 
            We only search for ISO14443A-type tags

        Returns:
            Returns array.array of unsigned chars containing UID of tag
            If no tag is found, returns None
        """
        cdef cnfci2c.nfc_modulation nm
        nm.nmt = cnfci2c.NMT_ISO14443A 
        nm.nbr = cnfci2c.NBR_106
        cdef array.array tag = array.array('B')
        cdef int result = cnfci2c.nfc_initiator_list_passive_targets(
                              self.__device, nm, &self.__target, 1)
        if result < 0:
            raise IOError("Error reading NFC tag")
        elif result > 0:
            for i in range(self.__target.nti.nai.szUidLen):
                tag.append(self.__target.nti.nai.abtUid[i])
            return(tag)
        else:
            return None

    cpdef bint isTagPresent(self):
        """Whether or not a tag is detected.

        Returns:
            True if a tag is present, false if not
        """
        cdef bint result = cnfci2c.nfc_initiator_target_is_present(
                                 self.__device, NULL)
        return(not result)

    cdef _wakeup(self, bytes connstring):
        # Tries to wake up the NFC module by quick writing to it
        if connstring:
            # get port number using magic
            i2c_num = int(bytes(connstring).rsplit(b'i2c-', 1)[1])

            success = False
            error_count = 0
            bus = smbus.SMBus(i2c_num)

            # try 5 times to wake up the chip
            while not success and error_count < 5:
                try:
                    bus.write_quick(0x24)
                except IOError as e:
                    error_count = error_count + 1
                else:
                    success = True
                finally:
                    # give chip time to wake up
                    time.sleep(0.5) 

            # if we still haven't woken up, then something's wrong
            if error_count >= 5:
                raise IOError("Cannot wake NFC device ")


