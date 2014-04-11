Billing Engine
====================

Currently, this engine support billing via Braintree. More backends to come later.

Configuration
----------------------------------

Start with a sandbox account, which you can get here: https://www.braintreepayments.com/get-started

Once you have registered for the sandbox, logging in will show you three important variables you will need to configure:

* merchantId
* publicKey
* privatekey

To configure the billing engine, edit `config/config.yaml` like so:

    production: (or "development", as you prefer)
      billing:
        braintree:
          environment: sandbox
          merchant_id: Ohp2aijaaqu6oJ4w
          public_key: ahnar0UwLahwe6Ce
          private_key: aemie2Geohgah2EaOad9DeeruW4Iegh4

If deploying via puppet, the same data in webapp.json would like this:

    "billing": {
      "braintree": {
        "environment": "sandbox",
        "merchant_id": "Ohp2aijaaqu6oJ4w",
        "public_key": "ahnar0UwLahwe6Ce",
        "private_key": "aemie2Geohgah2EaOad9DeeruW4Iegh4"
      }
    }

Now, you should be able to add charges to your own sandbox when you run the webapp.

The acceptable values for `billing.braintree.environment` are: `development`, `qa`, `sandbox`, or `production`.

Plans
--------------------------------

You also will want to add a Plan to your Sandbox. Within the Braintree Sandbox, navigate to 'Recurring Billing' -> 'Plans'. From here, you can add a new Plan. The values of the test plan are not important, but the ID will be displayed, so should pick something descriptive.

Here are credit cared numbers to try in the Sandbox:

https://www.braintreepayments.com/docs/ruby/reference/sandbox