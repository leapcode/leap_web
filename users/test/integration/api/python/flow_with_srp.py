#!/usr/bin/env python

# under development

import requests
import json
import string
import random
import srp
import binascii

# let's have some random name
def id_generator(size=6, chars=string.ascii_uppercase + string.digits):
  return ''.join(random.choice(chars) for x in range(size))

# using globals for a start
server = 'http://localhost:3000'
login = id_generator()
password = id_generator() + id_generator()

# log the server communication
def print_and_parse(response):
  print response.request.method + ': ' + response.url
  print "    " + json.dumps(response.request.data)
  print " -> " + response.text
  return json.loads(response.text)

def signup(session):
  salt, vkey = srp.create_salted_verification_key( login, password, srp.SHA256, srp.NG_1024 )
  user_params = {
      'user[login]': login,
      'user[password_verifier]': binascii.hexlify(vkey),
      'user[password_salt]': binascii.hexlify(salt)
      }
  return session.post(server + '/users.json', data = user_params)

usr = srp.User( login, password, srp.SHA256, srp.NG_1024 )

def authenticate(session, login):
  uname, A = usr.start_authentication()
  params = {
      'login': uname,
      'A': binascii.hexlify(A)
      }
  init = print_and_parse(session.post(server + '/sessions', data = params))
  M = usr.process_challenge( binascii.unhexlify(init['salt']), binascii.unhexlify(init['B']) )
  return session.put(server + '/sessions/' + login, 
      data = {'client_auth': binascii.hexlify(M)})

session = requests.session()
user = print_and_parse(signup(session))

# SRP signup would happen here and calculate M hex
auth = print_and_parse(authenticate(session, user['login']))
usr.verify_session( binascii.unhexlify(auth["M2"]) )

# At this point the authentication process is complete.
assert usr.authenticated()

