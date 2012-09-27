#!/usr/bin/env python

server = 'http://localhost:3000'

import requests
import json
import string
import random

def id_generator(size=6, chars=string.ascii_uppercase + string.digits):
  return ''.join(random.choice(chars) for x in range(size))

params = {
    'login': 'python_test_user_'+id_generator(),
    'A': '12345',
    }
r = requests.post(server + '/sessions', data = params)
print r.url
print r.text
