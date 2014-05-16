import srp._pysrp as srp
import binascii
import string
import random

safe_unhexlify = lambda x: binascii.unhexlify(x) if (
    len(x) % 2 == 0) else binascii.unhexlify('0' + x)

# let's have some random name and password
def id_generator(size=6, chars=string.ascii_lowercase + string.digits):
  return ''.join(random.choice(chars) for x in range(size))

class User():
    def __init__(self, config = None):
        if config and config.user:
            self.username = config.user["username"]
            self.password = config.user["password"]
        else:
            self.username = 'test_' + id_generator()
            self.password = id_generator() + id_generator()
        self.srp_user = srp.User(self.username, self.password, srp.SHA256, srp.NG_1024)

    def signup(self, api):
        salt, vkey = srp.create_salted_verification_key( self.username, self.password, srp.SHA256, srp.NG_1024 )
        user_params = {
            'user[login]': self.username,
            'user[password_verifier]': binascii.hexlify(vkey),
            'user[password_salt]': binascii.hexlify(salt)
        }
        return api.post('users.json', data = user_params)

    def login(self, api):
        init=self.init_authentication(api)
        if ('errors' in init):
            raise Exception('test user not found')
        auth=self.authenticate(api, init)
        if ('errors' in auth):
            raise Exception('srp password auth failed')
        self.verify_server(auth)
        if not self.is_authenticated():
            raise Exception('user is not authenticated')
        return auth

    def init_authentication(self, api):
        uname, A = self.srp_user.start_authentication()
        params = {
            'login': uname,
            'A': binascii.hexlify(A)
        }
        return api.post('sessions', data=params)

    def authenticate(self, api, init):
        M = self.srp_user.process_challenge(
            safe_unhexlify(init['salt']), safe_unhexlify(init['B']))
        auth = api.put('sessions/' + self.username,
                           data={'client_auth': binascii.hexlify(M)})
        return auth

    def verify_server(self, auth):
        self.srp_user.verify_session(safe_unhexlify(auth["M2"]))

    def is_authenticated(self):
        return self.srp_user.authenticated()

