#!/usr/bin/env python

# Test Soledad sync
#
# This script performs a slightly modified U1DB sync to the Soledad server and
# returns whether that sync was succesful or not.


import tempfile
import os
import shutil
import u1db
from support.api import Api
from support.config import Config
from support.user import User


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


# The following function could fetch all info needed to sync using soledad.
# Despite that, we won't use all that info because we are instead faking a
# Soledad sync by using U1DB slightly modified syncing capabilities. Part of
# the code is commented and left here for future reference, in case we decide
# to actually use the Soledad client in the future.

def get_soledad_info(config, tempdir):
    # get login and get user info
    user = User(config)
    api = Api(config, verify=False)
    auth = user.login(api)
    # get soledad server url
    soledad_hosts = api.get('config/soledad-service.json')['hosts']
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
    return auth['id'], server_url, cert_file, auth['token']


def can_sync_soledad_fine():
    tempdir = tempfile.mkdtemp()
    try:
        uuid, server_url, cert_file, token = \
              get_soledad_info(Config(), tempdir)
        # in the future, we can replace the following by an actual Soledad
        # client sync, if needed
        db = u1db.open(os.path.join(tempdir, '%s.db' % uuid), True)
        creds = {'token': {'uuid': uuid, 'token': token}}
        db.sync(server_url, creds=creds, autocreate=False)
    finally:
        shutil.rmtree(tempdir)

if __name__ == '__main__':
    from support import nagios_test
    exit_code = nagios_test.run(can_sync_soledad_fine)
    exit(exit_code)
