Billing Engine
====================

Currently, this engine support billing via Braintree. Braintree provides three
options for payments: Pay Pal, Bitcoin and Credit Cards.

Configuration
----------------------------------

Start with a sandbox account, which you can get here: https://www.braintreepayments.com/get-started
:q
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

How does it works
--------------------------------

The new implementation of Braintree uses its new API called 'v.zero'. It
consists of complementary client and server SDKs:

1. The JS client SDK enables you to collect payment method (e.g. credit card,
PayPal) details on your website
2. The server SDKs manage all requests to the Braintree gateway.

They represent the Client-side Encryption solution that combines Braintree’s
traditional Server-to-Server (S2S) approach and  Transparent Redirect (TR)
solution. It can be described as following:

1. The application server generates a client token for each customer (data blob)
using the Ruby SDK for the frontend that initializes the JavaScript SDK
using that client token.
2. The Braintree-provided JavaScript library encrypts sensitive data using the
public key and communicates with Braintree before the form is ever posted to
your server.
3. Once the data reaches Braintree’s servers, it is decrypted using the keypair’s
private key, then returns a payment method nonce to your client code. Your code
relays this nonce to your server.
4. Your server-side code provides the payment method nonce to the Ruby SDK to
perform Braintree operations (in this case either donations or subcriptions).

What is included
--------------------------------

Current implementation with 'v.zero' provides:
1. Donations and subscriptions.
2. Three payment methods: Bitcoin, Pay Pal and Credit Cards.
3. Creation and storage of customers (stored in 'The Vault')
4. Ability to donate as anonymous user.
5. Subscription or unsubscriptions to plans.
6. Recurring billing.
7. Storing Multiple Credit Cards.

Bitcoin
--------------------------------

In order for Bitcoin to work, you need to write Braintree's community and ask
them to allow that payment method. Bitcoin is implemented via Coinbase.
Learn about this here:
https://developers.braintreepayments.com/javascript+ruby/guides/coinbase/configuration
Contact: coinbase@braintreepayments.com
