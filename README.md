LEAP Web
---------------------

"LEAP Web" is the web-based component of the LEAP Platform, providing the following services:

* REST API for user registration.
* Admin interface to manage users.
* Client certificate distribution and renewal.
* User support help tickets.
* Billing

This web application is written in Ruby on Rails 3, using CouchDB as the backend data store.

Original code specific to this web application is licensed under the GNU Affero General Public License (version 3.0 or higher). See http://www.gnu.org/licenses/agpl-3.0.html for more information.

Documentation
---------------------------

For more information, see these files in the ``doc`` directory:

* DEPLOY -- for notes on deployment.
* DEVELOP -- for developer notes.
* CUSTOM -- how to customize.

Known problems
---------------------------

* Client certificates are generated without a CSR. The problem is that this makes the web
  application extremely vulnerable to denial of service attacks. This was not an issue until we
  started to allow the possibility of anonymously fetching a client certificate without
  authenticating first.

* By its very nature, the user database is vulnerable to enumeration attacks. These are
  very hard to prevent, because our protocol is designed to allow query of a user database via
  proxy in order to provide network perspective.

Installation
---------------------------

Typically, this application is installed automatically as part of the LEAP Platform. To install it manually for testing or development, follow these instructions:

### Install system requirements

    sudo apt-get install git ruby1.8 rubygems1.8 couchdb
    sudo gem install bundler

On Debian Wheezy or later, there is a Debian package for bundler, so you can alternately run ``sudo apt-get install bundler``.

### Download source

    git clone git://leap.se/leap_web
    cd leap_web
    git submodule update --init

### Install required ruby libraries

    cd leap_web
    bundle

Typically, you run ``bundle`` as a normal user and it will ask you for a sudo password when it is time to install the required gems. If you don't have sudo, run ``bundle`` as root.

Configuration
----------------------------

The configuration file `config/defaults.yml` providers good defaults for most
values. You can override these defaults by creating a file `config/config.yml`.

There are a few values you should make sure to modify:

    production:
      admins: ["myusername","otherusername"]
      domain: example.net
      force_ssl: true
      secret_token: "4be2f60fafaf615bd4a13b96bfccf2c2c905898dad34..."
      client_ca_key: "/etc/ssl/ca.key"
      client_ca_cert: "/etc/ssl/ca.crt"
      ca_key_password: nil

* `admins` is an array of usernames that are granted special admin privilege.
* `domain` is your fully qualified domain name.
* `force_ssl`, if set to true, will require secure cookies and turn on HSTS. Don't do this if you are using a self-signed server certificate.
* `secret_token`, used for cookie security, you can create one with `rake secret`. Should be at least 30 characters.
* `client_ca_key`, the private key of the CA used to generate client certificates.
* `client_ca_cert`, the public certificate the CA used to generate client certificates.
* `ca_key_password`, used to unlock the client_ca_key, if needed.

Running
-----------------------------

    cd leap_web
    rails server

Then open http://localhost:3000 in your web browser.

To peruse the database, visit http://localhost:5984/_utils/

Testing
--------------------------------

To run all tests

    rake test

To run an individual test:

    rake test TEST=certs/test/unit/client_certificate_test.rb
