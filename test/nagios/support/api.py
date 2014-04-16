import requests
import json

class Api():
    def __init__(self, config, verify=True):
        self.config = config.api
        self.session = requests.session()
        self.verify = verify
    
    def api_url(self, path):
        return self.api_root() + path

    def api_root(self):
        return "https://{domain}:{port}/{version}/".format(**self.config)

    def get(self, path, **args):
        response = self.session.get(self.api_url(path),
                verify=self.verify,
                **args)
        return response.json()

    def post(self, path, **args):
        response = self.session.post(self.api_url(path),
                verify=self.verify,
                **args)
        return response.json()

    def put(self, path, **args):
        response = self.session.put(self.api_url(path),
                verify=self.verify,
                **args)
        return response.json()

