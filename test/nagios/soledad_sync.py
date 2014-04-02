#!/usr/bin/env python

# Test Soledad sync
#
# This script performs a slightly modified U1DB sync to the Soledad server and
# returns whether that sync was succesful or not.


import tempfile
import requests
import os
import srp._pysrp as srp
import shutil
import u1db
import webapp_login


from u1db.remote.http_target import HTTPSyncTarget


# monkey patch U1DB's HTTPSyncTarget to perform token based auth

def set_token_credentials(self, uuid, token):
    self._creds = {'token': (uuid, token)}

def _sign_request(self, method, url_query, params):
    uuid, token = self._creds['token']
    auth = '%s:%s' % (uuid, token)
    return [('Authorization', 'Token %s' % auth.encode('base64')[:-1])]

HTTPSyncTarget.set_token_credentials = set_token_credentials
HTTPSyncTarget._sign_request = _sign_request


def fail(reason):
    print '2 soledad_sync - CRITICAL - ' + reason
    exit(2)

# monkey patch webapp_login's fail function to report as soledad
webapp_login.fail = fail


# The following function could fetch all info needed to sync using soledad.
# Despite that, we won't use all that info because we are instead faking a
# Soledad sync by using U1DB slightly modified syncing capabilities. Part of
# the code is commented and left here for future reference, in case we decide
# to actually use the Soledad client in the future.

def get_soledad_info(config, tempdir):
  # get login and get user info
  user = config['user']
  api = config['api']
  usr = srp.User( user['username'], user['password'], srp.SHA256, srp.NG_1024 )
  try:
    auth = webapp_login.parse(webapp_login.authenticate(api, usr))
  except requests.exceptions.ConnectionError:
    fail('no connection to server')
  # get soledad server url
  service_url = 'https://%s:%d/%d/config/soledad-service.json' % \
                (api['domain'], api['port'], api['version'])
  soledad_hosts = requests.get(service_url).json['hosts']
  host = soledad_hosts.keys()[0]
  server_url = 'https://%s:%d/user-%s' % \
               (soledad_hosts[host]['hostname'], soledad_hosts[host]['port'],
                auth['id'])
  # get provider ca certificate
  #ca_cert = requests.get('https://127.0.0.1/ca.crt', verify=False).text
  #cert_file = os.path.join(tempdir, 'ca.crt')
  cert_file = None  # not used for now
  #with open(cert_file, 'w') as f:
  #  f.write(ca_cert)
  return auth['id'], user['password'], server_url, cert_file, auth['token']


def run_tests():
  tempdir = tempfile.mkdtemp()
  uuid, password, server_url, cert_file, token = \
    get_soledad_info(webapp_login.read_config(), tempdir)
  exc = None
  try:
    # in the future, we can replace the following by an actual Soledad
    # client sync, if needed
    db = u1db.open(os.path.join(tempdir, '%s.db' % uuid), True)
    creds = {'token': {'uuid': uuid, 'token': token}}
    db.sync(server_url, creds=creds, autocreate=False)
  except Exception as e:
    exc = e
  shutil.rmtree(tempdir)
  exit(report(exc))


def report(exc):
  if exc is None:
    print '0 soledad_sync - OK - can sync soledad fine'
    return 0
  if isinstance(exc, u1db.errors.U1DBError):
    print '2 soledad_sync - CRITICAL - ' + exc.message
  else:
    print '2 soledad_sync - CRITICAL - ' + str(exc)
  return 2


if __name__ == '__main__':
  run_tests()
