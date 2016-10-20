Feature: Get service description for current user

  The LEAP provider can offer different services and their availability may
  depend upon a users service level - so wether they are paying or not.

  The /2/service endpoint allows the client to find out about the services
  available to the authenticated user.

  Background:
    Given I authenticated
    Given I set headers:
      | Accept       | application/json |
      | Content-Type | application/json |
      | Authorization | Token token="MY_AUTH_TOKEN" |

  Scenario: Get service settings
    When I send a GET request to "/2/service"
    Then the response status should be "200"
    And the response should be:
    """
      {
        "name": "free",
        "description": "free account, with rate limited VPN",
        "eip_rate_limit": true,
        "storage": 100,
        "services": [
          "eip"
        ]
      }
   """



