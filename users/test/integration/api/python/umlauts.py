#!/usr/bin/env python
# coding: utf-8

# under development

import requests
import json
import string
import random
import srp._pysrp as srp
import binascii

safe_unhexlify = lambda x: binascii.unhexlify(x) if (len(x) % 2 == 0) else binascii.unhexlify('0'+x)

# using globals for now
# server = 'https://dev.bitmask.net/1'
server = 'http://api.lvh.me:3000/1'

def run_tests():
  login = 'test_' + id_generator()
  password = id_generator() + "äöì" + id_generator()
  usr = srp.User( login, password, srp.SHA256, srp.NG_1024 )
  print_and_parse(signup(login, password))

  auth = print_and_parse(authenticate(usr))
  verify_or_debug(auth, usr)
  assert usr.authenticated()


# let's have some random name
def id_generator(size=6, chars=string.ascii_lowercase + string.digits):
  return ''.join(random.choice(chars) for x in range(size))

# log the server communication
def print_and_parse(response):
  request = response.request
  print request.method + ': ' + response.url
  if hasattr(request, 'data'):
    print "    " + json.dumps(response.request.data)
  print " -> " + response.text
  try: 
    return json.loads(response.text)
  except ValueError:
    return None

def signup(login, password):
  salt, vkey = srp.create_salted_verification_key( login, password, srp.SHA256, srp.NG_1024 )
  user_params = {
      'user[login]': login,
      'user[password_verifier]': binascii.hexlify(vkey),
      'user[password_salt]': binascii.hexlify(salt)
      }
  print json.dumps(user_params)
  return requests.post(server + '/users.json', data = user_params, verify = False)

def authenticate(usr):
  session = requests.session()
  uname, A = usr.start_authentication()
  params = {
      'login': uname,
      'A': binascii.hexlify(A)
      }
  init = print_and_parse(session.post(server + '/sessions', data = params, verify=False))
  M = usr.process_challenge( safe_unhexlify(init['salt']), safe_unhexlify(init['B']) )
  return session.put(server + '/sessions/' + uname, verify = False,
      data = {'client_auth': binascii.hexlify(M)})

def verify_or_debug(auth, usr):
  if ( 'errors' in auth ):
    print '    u = "%x"' % usr.u
    print '    x = "%x"' % usr.x
    print '    v = "%x"' % usr.v
    print '    S = "%x"' % usr.S
    print '    K = "' + binascii.hexlify(usr.K) + '"'
    print '    M = "' + binascii.hexlify(usr.M) + '"'
  else:
    usr.verify_session( safe_unhexlify(auth["M2"]) )

run_tests()
