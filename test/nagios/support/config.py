import yaml

class Config():
    def __init__(self, filename="/etc/leap/hiera.yaml"):
        with open("/etc/leap/hiera.yaml", 'r') as stream:
            config = yaml.load(stream)
        self.user = config['webapp']['nagios_test_user']
        if 'username' not in self.user:
            raise Exception('nagios test user lacks username')
        if 'password' not in self.user:
            raise Exception('nagios test user lacks password')
        self.api = config['api']
        self.api['version'] = config['webapp']['api_version']

