Feature: Business Rules
   This documents the business rules we have established for the application.
   Cleanse rules are described by a name and their effect on a simple example.

   Background:
      Given the standard business rules

   Scenario: 
      Given "phone" with value "555-555-5555"
      When I run the "separated phone" rule
      Then "phone" should be "(555) 555-5555"

   Scenario:
      Given "phone" with value "555.555.5555"
      When I run the "separated phone" rule
      Then "phone" should be "(555) 555-5555"

   Scenario:
      Given "phone" with value "7776668888"
      When I run the "all number phone" rule
      Then "phone" should be "(777) 666-8888"

   Scenario:
      Given "phone" with value "011555555555555"
      When I run the "international phone" rule
      Then "phone" should be "011 55 (555) 555-5555"

   Scenario:
      Given "a" with value " 88"
      And "b" with value " 99"
      And "c" with value "  67 "
      And "d" with value "83"
      And "e" with value nil
      When I run the "strip whitespace" rule
      Then "a" should be "88"
      And "b" should be "99"
      And "c" should be "67"
      And "d" should be "83"
      And "e" should be nil

   Scenario:
      Given "phone" with value "55555555555"
      When I run the "international phone" rule
      Then "phone" should be "5 (555) 555-5555"

   Scenario:
      Given "phone" with value "555555555555"
      When I run the "country code" rule
      Then "phone" should be "55 (555) 555-5555"
