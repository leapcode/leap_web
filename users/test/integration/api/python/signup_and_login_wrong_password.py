#!/usr/bin/env python

server = 'http://localhost:9292'

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
#  print " () " + json.dumps(requests.utils.dict_from_cookiejar(response.cookies))
  return json.loads(response.text)

def signup():
  user_params = {
      'user[login]': id_generator(),
      'user[password_verifier]': '12345',
      'user[password_salt]': '54321'
      }
  return requests.post(server + '/users.json', data = user_params)

def handshake(login):
  params = {
      'login': login,
      'A': '12345',
      }
  return requests.post(server + '/sessions', data = params)

def authenticate(login, M):
  return requests.put(server + '/sessions/' + login, data = {'M': M})


user = print_and_parse(signup())
handshake = print_and_parse(handshake(user['login']))
# SRP signup would happen here and calculate M hex
M = '123ABC'
auth = print_and_parse(authenticate(user['login'], M))
