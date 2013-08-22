#!/usr/bin/env python

# under development

import requests
import json
import string
import random
import srp._pysrp as srp
import binascii

safe_unhexlify = lambda x: binascii.unhexlify(x) if (len(x) % 2 == 0) else binascii.unhexlify('0'+x)

# let's have some random name
def id_generator(size=6, chars=string.ascii_lowercase + string.digits):
  return ''.join(random.choice(chars) for x in range(size))

# using globals for a start
server = 'https://dev.bitmask.net/1'
login = 'test_' + id_generator()
password = id_generator() + id_generator()

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

def signup(session):
  salt, vkey = srp.create_salted_verification_key( login, password, srp.SHA256, srp.NG_1024 )
  user_params = {
      'user[login]': login,
      'user[password_verifier]': binascii.hexlify(vkey),
      'user[password_salt]': binascii.hexlify(salt)
      }
  return session.post(server + '/users.json', data = user_params, verify = False)

def change_password(session):
  password = id_generator() + id_generator()
  salt, vkey = srp.create_salted_verification_key( login, password, srp.SHA256, srp.NG_1024 )
  user_params = {
      'user[password_verifier]': binascii.hexlify(vkey),
      'user[password_salt]': binascii.hexlify(salt)
      }
  print user_params
  print_and_parse(session.put(server + '/users/' + auth['id'] + '.json', data = user_params, verify = False))
  return srp.User( login, password, srp.SHA256, srp.NG_1024 )


def authenticate(session, login):
  uname, A = usr.start_authentication()
  params = {
      'login': uname,
      'A': binascii.hexlify(A)
      }
  init = print_and_parse(session.post(server + '/sessions', data = params, verify=False))
  M = usr.process_challenge( safe_unhexlify(init['salt']), safe_unhexlify(init['B']) )
  return session.put(server + '/sessions/' + login, verify = False,
      data = {'client_auth': binascii.hexlify(M)})

def verify_or_debug(auth):
  if ( 'errors' in auth ):
    print '    u = "%x"' % usr.u
    print '    x = "%x"' % usr.x
    print '    v = "%x"' % usr.v
    print '    S = "%x"' % usr.S
    print '    K = "' + binascii.hexlify(usr.K) + '"'
    print '    M = "' + binascii.hexlify(usr.M) + '"'
  else:
    usr.verify_session( safe_unhexlify(auth["M2"]) )

usr = srp.User( login, password, srp.SHA256, srp.NG_1024 )
session = requests.session()
user = print_and_parse(signup(session))

# SRP signup would happen here and calculate M hex
auth = print_and_parse(authenticate(session, user['login']))
verify_or_debug(auth)
assert usr.authenticated()

usr = change_password(session)

auth = print_and_parse(authenticate(session, user['login']))
verify_or_debug(auth)
# At this point the authentication process is complete.
assert usr.authenticated()

