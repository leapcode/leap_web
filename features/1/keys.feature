Feature: Handle current users collection of keys

  LEAP currently uses OpenPGP and is working on implementing katzenpost.
  Both systems require public keys of a user to be available for retrival.

  The /1/keys endpoint allows the client to manage the public keys
  registered for their users email address.

  You need to specify the type of the key when publishing it. Some
  keytypes such as 'openpgp' and 'katzenpost_id' will only allow a
  single key to be published. Others such as 'katzenpost_link' allow
  multiple keys to be registered at the same time. We deal with this
  by allowing arbitrary json data to be specified as the value of the
  key. So katzenpost_link keys can be combined in a json data structure.

  POST request will register a new key. In order to replace an existing
  key you need to send a PATCH request to /keys/:type including the last
  revision (rev) of the key. This way we can detect conflicts between
  concurrend updates.

  Background:
    Given I authenticated
    Given I set headers:
      | Accept       | application/json |
      | Content-Type | application/json |
      | Authorization | Token token="MY_AUTH_TOKEN" |

  Scenario: Get initial empty set of keys
    When I send a GET request to "1/keys"
    Then the response status should be "200"
    And the response should be:
    """
      {}
    """

  Scenario: Get all the keys
    Given I have published a "openpgp" key
    And I have published "katzenpost_kink" keys
    When I send a GET request to "1/keys"
    Then the response status should be "200"
    And the response should be:
    """
    {
    "openpgp": {
      "type": "openpgp",
      "value": "ASDF",
      "rev": "1234567890"
      },
    "katzenpost_link": {
      "type": "katzenpost_link",
      "value": {
        "one": "ASDF",
        "two": "QWER"
      },
      "rev": "1234567890"
      }
    }
    """

  Scenario: Get a single key
    Given I have published a "openpgp" key
    When I send a GET request to "1/keys/openpgp"
    Then the response status should be "200"
    And the response should be:
    """
    "ASDF"
    """

  Scenario: Get a set of keys for one type
    Given I have published "katzenpost_link" keys
    When I send a GET request to "1/keys/katzenpost_link"
    Then the response status should be "200"
    And the response should be:
    """
      {
        "one": "ASDF",
        "two": "QWER"
      }
    """

  Scenario: Publish an initial OpenPGP key
    When I send a POST request to "1/keys" with the following:
    """
      {
      "type": "openpgp",
      "value": "ASDF"
      }
    """
    Then the response status should be "204"

  Scenario: Do not overwrite an existing key
    Given I have published a "openpgp" key
    When I send a POST request to "1/keys" with the following:
    """
      {
      "type": "openpgp",
      "value": "QWER"
      }
    """
    Then the response status should be "422"
    And the response should be:
    """
      {
      "error": "key already exists"
      }
    """

  Scenario: Updating an existing key require revision
    Given I have published a "openpgp" key
    When I send a PATCH request to "1/keys/openpgp" with the following:
    """
      {
      "type": "openpgp",
      "value": "QWER"
      }
    """
    Then the response status should be "422"
    And the response should be:
    """
      {
      "error": "no revision specified"
      }
    """

  Scenario: Updating an existing key
    Given I have published a "openpgp" key with revision "1234567890"
    When I send a PATCH request to "1/keys/openpgp" with the following:
    """
      {
      "type": "openpgp",
      "value": "QWER",
      "rev": "1234567890"
      }
    """
    Then the response status should be "204"

  Scenario: Publishing an empty key fails
    When I send a POST request to "1/keys" with the following:
    """
      {}
    """
    Then the response status should be "422"
    And the response should be:
    """
      {
      "error": "key type missing"
      }
    """
