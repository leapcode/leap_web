#!/usr/bin/env python

# Test Authentication with the webapp API works.

import requests
import json
import string
import random
import srp._pysrp as srp
import binascii
import yaml
import report

safe_unhexlify = lambda x: binascii.unhexlify(x) if (
    len(x) % 2 == 0) else binascii.unhexlify('0' + x)

report.system = 'webapp login'

def read_config():
    with open("/etc/leap/hiera.yaml", 'r') as stream:
        config = yaml.load(stream)
    user = config['webapp']['nagios_test_user']
    if 'username' not in user:
        report.fail('nagios test user lacks username')
    if 'password' not in user:
        report.fail('nagios test user lacks password')
    api = config['api']
    api['version'] = config['webapp']['api_version']
    return {'api': api, 'user': user}


def run_tests(config):
    user = config['user']
    api = config['api']
    usr = srp.User(user['username'], user['password'], srp.SHA256, srp.NG_1024)
    try:
        auth = authenticate(api, usr)
    except requests.exceptions.ConnectionError:
        report.fail('no connection to server')
    if ('errors' in auth):
        report.fail('srp password auth failed')
    usr.verify_session(safe_unhexlify(auth["M2"]))
    if usr.authenticated():
        report.ok('can login to webapp fine')
    report.warn('failed to verify webapp server')

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
        report.fail('test user not found')
    M = usr.process_challenge(
        safe_unhexlify(init['salt']), safe_unhexlify(init['B']))
    response = session.put(api_url + '/sessions/' + uname, verify=False,
                       data={'client_auth': binascii.hexlify(M)})
    return response.json()

if __name__ == '__main__':
    run_tests(read_config())
