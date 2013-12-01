Feature: User account

    As a user,
    I want to be able to make an account on the site
    so that I can save my details without having to re-enter them each time.

Background: The user does not have an account on the site and he has a twitter account
    Given I am a new user to the site
    And I am on the Create Account page
    And I have filled in my twitter information

Scenario: Create account
    When I press Create Account
    Then I should have a new account
    And I should be on my user profile
