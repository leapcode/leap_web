#!/usr/bin/env python

# FAILS
#
# This test is currently failing for me because the session is not kept.
# Played with it a bunch - is probably messed up right now as well.


server = 'http://localhost:3000'

import requests
import json
import string
import random

def id_generator(size=6, chars=string.ascii_uppercase + string.digits):
  return ''.join(random.choice(chars) for x in range(size))

def print_and_parse(response):
  print response.request.method + ': ' + response.url
  print "    " + json.dumps(response.request.data)
  print " -> " + response.text
  return json.loads(response.text)

def signup(session):
  user_params = {
      'user[login]': id_generator(),
      'user[password_verifier]': '12345',
      'user[password_salt]': 'AB54321'
      }
  return session.post(server + '/users.json', data = user_params)

def authenticate(session, login):
  params = {
      'login': login,
      'A': '12345',
      }
  init = print_and_parse(session.post(server + '/sessions', data = params))
  return session.put(server + '/sessions/' + login, data = {'client_auth': '123'})

session = requests.session()
user = print_and_parse(signup(session))
# SRP signup would happen here and calculate M hex
auth = print_and_parse(authenticate(session, user['login']))
