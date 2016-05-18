@config
Feature: Anonymous access to EIP

  A provider may choose to allow anonymous access to EIP.
  In this case some endpoints that would normally require authentication
  will be available without authentication.

  Background: 
    Given "allow_anonymous_certs" is enabled in the config
    And I set headers:
      | Accept       | application/json |
      | Content-Type | application/json |

  Scenario: Fetch configs when anonymous certs are allowed
    When I send a GET request to "/1/configs.json"
    Then the response status should be "200"

  Scenario: Fetch EIP config when anonymous certs are allowed
    Given there is a config for the eip
    When I send a GET request to "/1/configs/eip-service.json"
    Then the response status should be "200"

  Scenario: Fetch service description
    When I send a GET request to "/1/service.json"
    Then the response status should be "200"
    And the response should be:
    """
      {
        "name": "anonymous",
        "description": "anonymous access to the VPN",
        "eip_rate_limit": false
      }
    """

