Feature: Authentication

  Authentication is handled with SRP. Once the SRP handshake has been successful a token will be transmitted. This token is used to authenticate further requests.

  In the scenarios MY_AUTH_TOKEN will serve as a placeholder for the actual token received.

  Background:
    Given I set headers:
      | Accept        | application/json |
      | Content-Type  | application/json |

  Scenario: Submitting a valid token
    Given I authenticated
    And I set headers:
      | Authorization | Token token="MY_AUTH_TOKEN" |
    When I send a GET request to "/2/configs.json"
    Then the response status should be "200"

  Scenario: Submitting an invalid token
    Given I authenticated
    And I set headers:
      | Authorization | Token token="InvalidToken" |
    When I send a GET request to "/2/configs.json"
    Then the response status should be "401"
