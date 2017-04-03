version 0.9 (unreleased) - twitter feed, rails 4 and deprecations
----------------------------------------------------

This release features a great contribution from the Rails Girls Summer of Code
again! The landing page of the webapp can now include a twitter feed to display
news from the provider.
Other than that this is a maintainance and transition release.

* Twitter feed on main page (thanks theaamanda and lilaluca).
* upgrade to rails 4.2
* upgrade to bootstrap 3

Upgrading:

* We now use rails 4's `secret_key_base`. Please make sure to supply it
  in config/config.yml for production environments. If you are using the
  leap platform that will already take care of it.

Deprecations:

* We have not seen any active use of the **billing** functionality.
  So we deprecate it and will probably drop it in one of the next releases.
* We will replace the user facing **help desk** functionality with a single
  sign on mechanism to integrate with other help desk systems.
  We will maintain the endpoint to submit tickets and the ticket management
  in the admin interface. That way it should also be easy to create your own
  ticket submission form.
* We deprecate the ability to **signup and login** directly through the webapp.
  We will remove it in the future for security reasons. Signup and Login should
  only happen through bitmask to prevent password phishing and js injections.



version 0.8 - email and RGSoC
------------------------------------------

This release focused on getting all the features needed for a complete
email provider and merging in the work done by Rails Girls Summer of
Code.

* Support for invite codes: admins can require that new
  users present an invite code. If required, the invite code
  cannot be bypassed and is incorporated in the Secure Remote
  Password negotiation. (thanks ankonym, ayajaff).
* Support for customer account billing, including subscriptions.
  (thanks claucece, EvyW).
* Ability to remove, disable, and re-enable users.
  (thanks EvyW).
* Many localization fixes.
* Many bug fixes.

version 0.7.1 - localization
------------------------------------------

Support for localization has been turned on and much improved. Since you
probably don't want to enable all the available languages, make sure to set
`default_locale` and `available_locales` in your configuration file.

When deploying via the LEAP platform, these are controlled via
`default_locale` and `languages` in provider.json.

version 0.7 - rotating DBs
------------------------------------------

CouchDB is not designed to handle ephemeral data, like sessions, because
documents are never really deleted (a tombstone document is always kept to
record the deletion). To overcome this limitation, we now rotate the
`sessions` and `tokens` databases monthly. The new database names are
`tokens_XXX` and `sessions_XXX` where XXX is a counter since the epoch that
increments every month (not a calendar month, but a month's worth of seconds).
Additionally, nagios checks and `leap test run` now will create and destroy
test users in the `tmp_users` database, which will get periodically deleted
and recreated.

