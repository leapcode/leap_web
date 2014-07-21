Feature: Unauthenticated API endpoints

  Most of the LEAP Provider API requires authentication.
  However there are a few exceptions - mostly prerequisits of authenticating. This feature and the authentication feature document these.

  Background:
    Given I set headers:
      | Accept       | application/json |
      | Content-Type | application/json |

  @tempfile
  Scenario: Fetch provider config
    Given the provider config is:
      """
      {"config": "me"}
      """
    When I send a GET request to "/provider.json"
    Then the response status should be "200"
    And the response should be:
      """
      {"config": "me"}
      """

  @config
  Scenario: Fetch configs when anonymous certs are allowed
    Given "allow_anonymous_certs" is enabled in the config
    When I send a GET request to "/1/configs.json"
    Then the response status should be "200"

  Scenario: Authentication required response
    When I send a GET request to "/1/configs"
    Then the response status should be "401"
    And the response should have "error" with "not_authorized_login"
    And the response should have "message"

  Scenario: Authentication required for all other API endpoints (incomplete)
    Given I am not logged in
    When I send requests to these endpoints:
      |  GET   | /1/configs                |
      |  GET   | /1/configs/config_id.json |
      | DELETE | /1/logout                 |
    Then they should require authentication
