#!/usr/bin/env python

# Test Authentication with the webapp API works.

import requests
import json
import string
import random
import srp._pysrp as srp
import binascii
import yaml


safe_unhexlify = lambda x: binascii.unhexlify(x) if (len(x) % 2 == 0) else binascii.unhexlify('0'+x)

def read_config():
  stream = open("/etc/leap/hiera.yaml", 'r')
  config = yaml.load(stream)
  stream.close
  user = config['webapp']['nagios_test_user']
  if ( 'username' not in user ):
    fail('nagios test user lacks username')
  if ( 'password' not in user ):
    fail('nagios test user lacks password')
  api = config['api']
  api['version'] = config['webapp']['api_version']
  return {'api': api, 'user': user}

def run_tests(config):
  user = config['user']
  api = config['api']
  usr = srp.User( user['username'], user['password'], srp.SHA256, srp.NG_1024 )
  try:
    auth = parse(authenticate(api, usr))
  except requests.exceptions.ConnectionError:
    fail('no connection to server')
  exit(report(auth, usr))

# parse the server responses
def parse(response):
  request = response.request
  try: 
    return json.loads(response.text)
  except ValueError:
    return None

def authenticate(api, usr):
  api_url = 'https://' + api['domain'] + ':' + str(api['port']) + '/' + str(api['version'])
  session = requests.session()
  uname, A = usr.start_authentication()
  params = {
      'login': uname,
      'A': binascii.hexlify(A)
      }
  init = parse(session.post(api_url + '/sessions', data = params, verify=False))
  if ( 'errors' in init ):
    fail('test user not found')
  M = usr.process_challenge( safe_unhexlify(init['salt']), safe_unhexlify(init['B']) )
  return session.put(api_url + '/sessions/' + uname, verify = False,
      data = {'client_auth': binascii.hexlify(M)})

def report(auth, usr):
  if ( 'errors' in auth ):
    fail('srp password auth failed')
  usr.verify_session( safe_unhexlify(auth["M2"]) )
  if usr.authenticated():
    print '0 webapp_login - OK - can login to webapp fine'
    return 0
  print '1 webapp_login - WARNING - failed to verify webapp server'
  return 1

def fail(reason):
  print '2 webapp_login - CRITICAL - ' + reason
  exit(2)

run_tests(read_config())
