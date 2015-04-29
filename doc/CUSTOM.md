Customization
==============================

Customization directory
---------------------------------------

See config/customization/README.md

Engines
---------------------

Leap Web includes some Engines. All things in `app` will overwrite the engine behaviour. You can clone the leap web repository and add your customizations to the `app` directory. Including leap_web as a gem is currently not supported. It should not require too much work though and we would be happy to include the changes required.

If you have no use for one of the engines you can remove it from the Gemfile. Engines should really be plugins - no other engines should depend upon them. If you need functionality in different engines it should probably go into the toplevel. The 'users' engine will soon become part of the main webapp for that reason.
