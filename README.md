LEAP Web
---------------------

The LEAP Web App provides the following functions:

* User registration and management
* Help tickets
* Client certificate renewal
* Webfinger access to user’s public keys
* Email aliases and forwarding
* Localized and Customizable documentation

Written in: Ruby, Rails.

The Web App communicates with:

* CouchDB is used for all data storage.
* Web browsers of users accessing the user interface in order to edit their settings or fill out help tickets. Additionally, admins may delete users.
* LEAP Clients access the web app’s REST API in order to register new users, authenticate existing ones, and renew client certificates.
* tokens are stored upon successful authentication to allow the client to authenticate against other services

LEAP Web is provisioned and run as part of the overall [LEAP platform](https://leap.se/en/docs/platform).

Original code specific to this web application is licensed under the GNU
Affero General Public License (version 3.0 or higher). See
http://www.gnu.org/licenses/agpl-3.0.html for more information.


Documentation
---------------------------

For more information, see these files in the ``doc`` directory:

* DEPLOY -- for notes on deployment.
* DEVELOP -- for developer notes.
* CUSTOM -- how to customize.

External docs:

* [Overview of LEAP architecture](https://leap.se/en/docs/design/overview) - Bird's eye view of how all the pieces fit together.
* [Contributing](https://leap.se/en/docs/get-involved) - Contributing to LEAP software development.
  * Contributing to LEAP software development
  * How to issue a pull request
  * Overview of the main code repositories
  * Ideas for discrete, unclaimed development projects that would greatly benefit the LEAP ecosystem.

Known problems
---------------------------

* Client certificates are generated without a CSR. The problem is that
  this makes the web application extremely vulnerable to denial of
  service attacks. This is not an issue unless the provider enables the
  possibility of anonymously fetching a client certificate without
  authenticating first.

* By its very nature, the user database is vulnerable to enumeration
  attacks. These are very hard to prevent, because our protocol is
  designed to allow query of a user database via proxy in order to
  provide network perspective.

Installation
---------------------------

Typically, this application is installed automatically as part of the
LEAP Platform. To install it manually for testing or development, follow
these instructions:

### Install system requirements

    sudo apt-get install git ruby1.9.3 rubygems couchdb
    sudo gem install bundler

On Debian Wheezy or later, there is a Debian package for bundler, so you
can alternately run ``sudo apt-get install bundler``.

### Download source

    git clone git://leap.se/leap_web
    cd leap_web
    git submodule update --init

### Install required ruby libraries

    cd leap_web
    bundle --binstubs

Typically, you run ``bundle`` as a normal user and it will ask you for a
sudo password when it is time to install the required gems. If you don't
have sudo, run ``bundle`` as root.

### Installation for development purposes

Please see `doc/DEVELOP.md` for further required steps when installing
leap_web for development purposes.

Configuration
----------------------------

The configuration file `config/defaults.yml` providers good defaults for
most values. You can override these defaults by creating a file
`config/config.yml`.

There are a few values you should make sure to modify:

    production:
      admins: ["myusername","otherusername"]
      domain: example.net
      force_ssl: true
      secret_token: "4be2f60fafaf615bd4a13b96bfccf2c2c905898dad34..."
      client_ca_key: "/etc/ssl/ca.key"
      client_ca_cert: "/etc/ssl/ca.crt"
      ca_key_password: nil

* `admins` is an array of usernames that are granted special admin
   privilege.

* `domain` is your fully qualified domain name.

* `force_ssl`, if set to true, will require secure cookies and turn on
   HSTS. Don't do this if you are using a self-signed server certificate.

* `secret_token`, used for cookie security, you can create one with
  `rake secret`. Should be at least 30 characters.

* `client_ca_key`, the private key of the CA used to generate client
   certificates.

* `client_ca_cert`, the public certificate the CA used to generate client
   certificates.

* `ca_key_password`, used to unlock the client_ca_key, if needed.

Running
-----------------------------

To run leap_web:

    cd leap_web
    bin/rake db:rotate
    bin/rake db:migrate
    bin/rails server

Then open http://localhost:3000 in your web browser.

When running in development mode, you can login with administrative
powers by creating an account with username 'staff', 'blue', or 'red'
(configured in config/default.yml).

To peruse the database, visit http://localhost:5984/_utils/

The task `db:rotate` must come before `db:migrate`, in order to assure that
the special rotating databases get created.

Do not run the normal CouchRest task 'couchrest:migrate'. Instead, use
'db:rotate' since the latter will correctly use the couchdb.admin.yml file.

Testing
--------------------------------

To run all tests

    bin/rake RAILS_ENV=test db:rotate    # if not already run
    bin/rake RAILS_ENV=test db:migrate   # if not already run
    bin/rake test

To run an individual test:

    rake test TEST=certs/test/unit/client_certificate_test.rb
    or
    ruby -Itest certs/test/unit/client_certificate_test.rb

