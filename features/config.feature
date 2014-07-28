Feature: Download Provider Configuration

  The LEAP Provider exposes parts of its configuration through the API.

  This can be used to find out about services offered. The big picture can be retrieved from `/provider.json`. Which is available without authentication (see unauthenticated.feature).
  
  More detailed settings of the services are available after authentication. You can get a list of the available settings from `/1/configs.json`.

  Background:
    Given I authenticated
    Given I set headers:
      | Accept       | application/json |
      | Content-Type | application/json |
      | Authorization | Token token="MY_AUTH_TOKEN" |

  @tempfile
  Scenario: Fetch provider config
    Given there is a config for the provider
    When I send a GET request to "/provider.json"
    Then the response status should be "200"
    And the response should be that config

  Scenario: Missing provider config
    When I send a GET request to "/provider.json"
    Then the response status should be "404"
    And the response should have "error" with "not_found"

  Scenario: Fetch list of available configs
    When I send a GET request to "/1/configs.json"
    Then the response status should be "200"
    And the response should be:
      """
      {
        "services": {
          "soledad": "/1/configs/soledad-service.json",
          "eip": "/1/configs/eip-service.json",
          "smtp": "/1/configs/smtp-service.json"
        }
      }
      """
  
  Scenario: Attempt to fetch an invalid config
    When I send a GET request to "/1/configs/non-existing.json"
    Then the response status should be "403"

  Scenario: Attempt to fetch a config that is missing on the server
    When I send a GET request to "/1/configs/eip-service.json"
    Then the response status should be "404"

  @tempfile, @config
  Scenario: Attempt to fetch the EIP config
    Given there is a config for the eip
    When I send a GET request to "/1/configs/eip-service.json"
    Then the response status should be "200"
    And the response should be that config

