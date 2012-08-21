#!/usr/bin/env python
#-*- coding: utf-8 -*-

"""
    This file defines Meta data, according to PEP314 
    (http://www.python.org/dev/peps/pep-0314/)
"""

VERSION_INFO = (0, 0, 2)
DATE_INFO = (2012, 8,  21) # YEAR, MONTH, DAY
VERSION = '.'.join(str(i) for i in VERSION_INFO)
REVISION = '%04d%02d%02d' % DATE_INFO
AUTHOR = "Edoardo Tenani (Endorama)"
AUTHOR_EMAIL = 'edoardo.tenani@gmail.com'
URL = ''
DOWNLOAD_URL = ''
LICENSE = "MIT License"
PROJECT = "UberInstaller"
DESCRIPTION = "Easily configure a fresh Ubuntu installation"
LONG_DESCRIPTION = """"""

if __name__ == "__main__":
    print('VERSION      = ' + VERSION)
    print('REVISION     = ' + REVISION)
    print('AUTHOR       = ' + AUTHOR)
    print('AUTHOR_EMAIL = ' + AUTHOR_EMAIL)
    print('URL          = ' + URL)
    print('LICENSE      = ' + LICENSE)
    print('PROJECT      = ' + PROJECT)
    print('DESCRIPTION  = ' + DESCRIPTION)
