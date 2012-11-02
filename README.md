LEAP Web
---------------------

"LEAP Web" is the web-based component of the LEAP Platform, providing the following services:

* REST API for user registration.
* Admin interface to manage users.
* Client certificate distribution and renewal.
* User support help tickets.

This web application is written in Ruby on Rails 3, using CouchDB as the backend data store.

Original code specific to this web application is licensed under the GNU Affero General Public License (version 3.0 or higher). See http://www.gnu.org/licenses/agpl-3.0.html for more information.

Documentation
---------------------------

For more information, see these files in the ``doc`` directory:

* DEPLOY -- for notes on deployment.
* DEVELOP -- for developer notes.
* CUSTOM -- how to customize.

Installation
---------------------------

Typically, this application is installed automatically as part of the LEAP Platform. To install it manually for testing or development, follow these instructions:

### Install system requirements

    sudo apt-get install git ruby1.8 rubygems1.8 couchdb
    sudo gem bundler

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

The webapp can hand out certs for the EIP client. These certs are either picked from a pool in CouchDB or from a file. For now you can either run [Leap CA](http://github.com/leapcode/leap_ca) to fill the pool or you can put your certs file in config/cert.

We also ship provider information through the webapp. For now please add your eip-service.json to the public/config directory.

Copy the example configuration file and customize as appropriate:
     cp config/config.yml.example config/config.yml

Running
-----------------------------

    cd leap_web
    rails server

Then open http://localhost:3000 in your web browser.

To peruse the database, visit http://localhost:5984/_utils/

