General Information
===================
This module provides a Python wrapper for interfacing the C-based
libnfc library, used to access NFC devices over the I2C bus.

More information about libnfc can be found at
  http://www.nfc-tools.org

The wrapper code is written using Cython. To build the wrapper library,
use the command

    python setup.py build_ext --inplace


