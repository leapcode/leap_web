Feature: Unauthenticated API endpoints

  Most of the LEAP Provider API requires authentication.
  However there are a few exceptions - mostly prerequisits of authenticating. This feature and the authentication feature document these.

  Background:
    Given I set headers:
      | Accept       | application/json |
      | Content-Type | application/json |

  @tempfile
  Scenario: Fetch provider config
    Given there is a config for the provider
    When I send a GET request to "/provider.json"
    Then the response status should be "200"
    And the response should be that config

  Scenario: Fetch list of available configs
    When I send a GET request to "/2/configs.json"
    Then the response status should be "200"
    And the response should be:
      """
      {
        "services": {
          "soledad": "/2/configs/soledad-service.json",
          "eip": "/2/configs/eip-service.json",
          "smtp": "/2/configs/smtp-service.json"
        }
      }
      """

  Scenario: Authentication required response
    When I send a GET request to "/2/configs/config_id.json"
    Then the response status should be "401"
    And the response should have "error" with "not_authorized_login"
    And the response should have "message"

  Scenario: Authentication required for all other API endpoints (incomplete)
    Given I am not logged in
    When I send requests to these endpoints:
      |  GET   | /2/configs/config_id.json |
      |  GET   | /2/service                |
      | DELETE | /2/logout                 |
    Then they should require authentication
