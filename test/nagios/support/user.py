import srp._pysrp as srp
import binascii

safe_unhexlify = lambda x: binascii.unhexlify(x) if (
    len(x) % 2 == 0) else binascii.unhexlify('0' + x)

class User():
    def __init__(self, config):
        self.config = config.user
        self.srp_user = srp.User(self.config['username'], self.config['password'], srp.SHA256, srp.NG_1024)

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
        auth = api.put('sessions/' + self.config["username"],
                           data={'client_auth': binascii.hexlify(M)})
        return auth

    def verify_server(self, auth):
        self.srp_user.verify_session(safe_unhexlify(auth["M2"]))

    def is_authenticated(self):
        return self.srp_user.authenticated()

