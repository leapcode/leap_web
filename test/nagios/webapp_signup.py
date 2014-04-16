#!/usr/bin/env python

# Test Signup and Login with the webapp API works.

from support.api import Api
from support.config import Config
from support.user import User

def signup_successfully():
    config = Config()
    user = User()
    api = Api(config, verify=False)
    user.signup(api)
    user.login(api)

if __name__ == '__main__':
    from support import nagios_test
    exit_code = nagios_test.run(signup_successfully)
    exit(exit_code)
