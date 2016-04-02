Feature: Receive messages for the user

  In order to stay in touch with the provider
  As an authenticated user
  I want to receive messages from the provider

  Background:
    Given I authenticated
    Given I set headers:
      | Accept       | application/json |
      | Content-Type | application/json |
      | Authorization | Token token="MY_AUTH_TOKEN" |

  Scenario: There are no messages yet
    When I send a GET request to "/1/messages.json"
    Then the response status should be "200"
    And the response should be:
      """
      []
      """

  Scenario: Fetch the unread messages
    Given there is a message for me with:
      | id   | 1a2b3c4d |
      | text | Your provider says hi ! |
    When I send a GET request to "/1/messages.json"
    Then the response status should be "200"
    And the response should be:
      """
      [{
       "id": "1a2b3c4d",
       "text": "Your provider says hi !"
      }]
      """

  Scenario: Send unread messages until marked as read
    Given there is a message for me
    And I have sent a GET request to "/1/messages.json"
    When I send a GET request to "/1/messages.json"
    Then the response status should be "200"
    And the response should include that message

  Scenario: Mark message as read
    Given there is a message for me with:
      | id   | 1a2b3c4d |
    When I send a PUT request to "/1/messages/1a2b3c4d.json"
    Then that message should be marked as read
    And the response status should be "200"
    And the response should have "success" with "marked_as_read"
    And the response should have "message"

  Scenario: Message not found
    When I send a PUT request to "/1/messages/1a2b3c4d.json"
    Then the response status should be "404"
    And the response should have "error" with "not_found"
    And the response should have "message"

  Scenario: Do not send read messages
    Given there is a message for me
    And that message is marked as read
    When I send a GET request to "/1/messages.json"
    Then the response status should be "200"
    And the response should be:
      """
      []
      """
