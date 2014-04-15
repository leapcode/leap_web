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

def read_config():
    with open("/etc/leap/hiera.yaml", 'r') as stream:
        config = yaml.load(stream)
    user = config['webapp']['nagios_test_user']
    if 'username' not in user:
        raise Exception('nagios test user lacks username')
    if 'password' not in user:
        raise Exception('nagios test user lacks password')
    api = config['api']
    api['version'] = config['webapp']['api_version']
    return {'api': api, 'user': user}


def login_successfully(config=None):
    config = config or read_config()
    user = config['user']
    api = config['api']
    usr = srp.User(user['username'], user['password'], srp.SHA256, srp.NG_1024)
    auth = authenticate(api, usr)
    if ('errors' in auth):
        raise Exception('srp password auth failed')
    usr.verify_session(safe_unhexlify(auth["M2"]))
    if not usr.authenticated():
        return 'failed to verify webapp server'

def authenticate(api, usr):
    api_url = "https://{domain}:{port}/{version}".format(**api)
    session = requests.session()
    uname, A = usr.start_authentication()
    params = {
        'login': uname,
        'A': binascii.hexlify(A)
    }
    response = session.post(api_url + '/sessions', data=params, verify=False)
    init = response.json()
    if ('errors' in init):
        raise Exception('test user not found')
    M = usr.process_challenge(
        safe_unhexlify(init['salt']), safe_unhexlify(init['B']))
    response = session.put(api_url + '/sessions/' + uname, verify=False,
                       data={'client_auth': binascii.hexlify(M)})
    return response.json()

if __name__ == '__main__':
    import nagios_test
    exit_code = nagios_test.run(login_successfully)
    exit(exit_code)
