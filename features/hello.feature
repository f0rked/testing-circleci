Feature: Hello command work as expected
  As a user
  In order to be happy
  I need to be sure hello works properly

  Scenario: Invoked without parameter returns default greeting
    When I invoke hello with parameter ""
    Then I get 0 as error code
    And I get "Hello Visitor!!" as output text

  Scenario: Invoked with a valid parameter returns the personalized greeting
    When I invoke hello with parameter "Hector"
    Then I get 0 as error code
    And I get "Hello Hector!!" as output text

  Scenario Outline: Invoked with invalid parameter returns an error
    When I invoke hello with parameter "<param>"
    Then I get 1 as error code
    And I get "Invalid name" as error text

    Examples:
      | param  |
      | Metr:  |
      | Héctor |
      | Tr3s   |
