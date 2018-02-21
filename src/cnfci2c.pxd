"""Wrapper for libnfc I2C interface.
This is a bare-minimum wrapper, only including the typedefs 
and functions that I needed.

Author: Mac Baker (bakerjm24450.dev@gmail.com)

Notes:
    This code was built using Cython

"""

cdef extern from "<nfc/nfc.h>":
    ctypedef unsigned char uint8_t
    ctypedef struct nfc_context:
        pass
    ctypedef struct nfc_device:
        pass
    ctypedef enum nfc_modulation_type:
        NMT_ISO14443A = 1
        NMT_JEWEL
        NMT_ISO14443B
        NMT_ISO14443BI
        NMT_ISO14443B2SR
        NMT_ISO14443B2CT
        NMT_FELICA
        NMT_DEP
        pass
    ctypedef enum nfc_baud_rate:
        NBR_UNDEFINED = 0
        NBR_106
        NBR_212
        NBR_424
        NBR_847
        pass
    ctypedef struct nfc_modulation:
        nfc_modulation_type nmt
        nfc_baud_rate nbr
        pass
    ctypedef struct nfc_iso14443a_info:
        size_t szUidLen
        uint8_t abtUid[10]
        pass
    ctypedef union nfc_target_info:
        nfc_iso14443a_info nai
        pass
    ctypedef struct nfc_target:
        nfc_target_info nti
        nfc_modulation nm
        pass
    ctypedef char* nfc_connstring

    void nfc_init(nfc_context **context)
    nfc_device* nfc_open(nfc_context *context, const nfc_connstring connstring)
    int nfc_initiator_init(nfc_device *device)
    int nfc_initiator_list_passive_targets(nfc_device *device,
                                           const nfc_modulation modulation,
                                           nfc_target *target,
                                           const size_t numTargets)
    bint nfc_initiator_target_is_present(nfc_device *device, const nfc_target* target)
    void nfc_close(nfc_device* device)
    void nfc_exit(nfc_context* context)
