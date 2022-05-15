# -*- coding: utf-8 -*-
"""
    websiteconfig
    ~~~~~~~~~~~~~

    default config for website.
"""

import os


class default_settings(object):
    DEBUG = True
    TESTING = True

    SECRET_KEY = 'Iza9JDcw/jy5Np5puozAJv6ckQ6diRgI'

    SQLALCHEMY_ECHO = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///%s/instance/website.db' % os.path.abspath(os.path.dirname(__file__))

    # USER_LOGIN_URL = '/login'
    # USER_LOGOUT_URL = '/logout'