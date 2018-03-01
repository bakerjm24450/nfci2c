#from distutils.core import setup
#from distutils.extension import Extension
from setuptools import setup, Extension
#from Cython.Build import cythonize

extensions = [
    Extension('nfci2c', 
        sources=['src/nfci2c.pyx'],
        libraries=['nfc']),
]
setup(
    name='nfci2c',
    version='1.1',
    author='Mac Baker',
    author_email='bakerjm24450.dev@gmail.com',
    description='Python wrapper for libnfc I2C interface',
    setup_requires=[
        'setuptools>=18.0',
        'cython'
    ],
    ext_modules = extensions,
)
