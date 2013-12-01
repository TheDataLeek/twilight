Feature: User account

    As a user, 
    I want to be able to make an account on the site 
    so that I can save my details without having to re-enter them each time.

Background: The user does not have an account on the site and he has a twitter account


Senario: Create account
 
    Given I am a new user to the site
    And I click on create an account
    Then I am on the create account page
    Given I fill in my twitter information
    Then I should have have an account
    And I should be on my user profile
