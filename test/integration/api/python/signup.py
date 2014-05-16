#!/usr/bin/env python

server = 'http://localhost:3000'

import requests
import json
import string
import random

def id_generator(size=6, chars=string.ascii_uppercase + string.digits):
  return ''.join(random.choice(chars) for x in range(size))

user_params = {
    'user[login]': 'python_test_user_'+id_generator(),
    'user[password_verifier]': '12345',
    'user[password_salt]': '54321'
    }
r = requests.post(server + '/users.json', data = user_params)
print r.url
print r.text
