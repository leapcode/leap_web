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

