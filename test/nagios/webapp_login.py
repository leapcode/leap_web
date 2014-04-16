#!/usr/bin/env python

# Test Authentication with the webapp API works.

import string
import random
from support.api import Api
from support.config import Config
from support.user import User

def login_successfully():
    config = Config()
    user = User(config)
    api = Api(config, verify=False)
    user.login(api)

if __name__ == '__main__':
    from support import nagios_test
    exit_code = nagios_test.run(login_successfully)
    exit(exit_code)
