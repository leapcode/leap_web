#!/usr/bin/env python

# Test Authentication with the webapp API works.

import requests
import json
import string
import random
import srp._pysrp as srp
import binascii
import yaml

safe_unhexlify = lambda x: binascii.unhexlify(x) if (
    len(x) % 2 == 0) else binascii.unhexlify('0' + x)

class Config():
    def __init__(self, filename="/etc/leap/hiera.yaml"):
        with open("/etc/leap/hiera.yaml", 'r') as stream:
            config = yaml.load(stream)
        self.user = config['webapp']['nagios_test_user']
        if 'username' not in self.user:
            raise Exception('nagios test user lacks username')
        if 'password' not in self.user:
            raise Exception('nagios test user lacks password')
        self.api = config['api']
        self.api['version'] = config['webapp']['api_version']

class Api():
    def __init__(self, config, verify=True):
        self.config = config.api
        self.session = requests.session()
        self.verify = verify
    
    def api_url(self, path):
        return self.api_root() + path

    def api_root(self):
        return "https://{domain}:{port}/{version}/".format(**self.config)

    def get(self, path, **args):
        response = self.session.get(self.api_url(path),
                verify=self.verify,
                **args)
        return response.json()

    def post(self, path, **args):
        response = self.session.post(self.api_url(path),
                verify=self.verify,
                **args)
        return response.json()

    def put(self, path, **args):
        response = self.session.put(self.api_url(path),
                verify=self.verify,
                **args)
        return response.json()

class User():
    def __init__(self, config):
        self.config = config.user
        self.srp_user = srp.User(self.config['username'], self.config['password'], srp.SHA256, srp.NG_1024)

    def login(self, api):
        init=self.init_authentication(api)
        if ('errors' in init):
            raise Exception('test user not found')
        auth=self.authenticate(api, init)
        if ('errors' in auth):
            raise Exception('srp password auth failed')
        self.verify_server(auth)
        if not self.is_authenticated():
            raise Exception('user is not authenticated')

    def init_authentication(self, api):
        uname, A = self.srp_user.start_authentication()
        params = {
            'login': uname,
            'A': binascii.hexlify(A)
        }
        return api.post('sessions', data=params)

    def authenticate(self, api, init):
        M = self.srp_user.process_challenge(
            safe_unhexlify(init['salt']), safe_unhexlify(init['B']))
        auth = api.put('sessions/' + self.config["username"],
                           data={'client_auth': binascii.hexlify(M)})
        return auth

    def verify_server(self, auth):
        self.srp_user.verify_session(safe_unhexlify(auth["M2"]))

    def is_authenticated(self):
        return self.srp_user.authenticated()


def login_successfully():
    config = Config()
    user = User(config)
    api = Api(config, verify=False)
    user.login(api)

if __name__ == '__main__':
    import nagios_test
    exit_code = nagios_test.run(login_successfully)
    exit(exit_code)
