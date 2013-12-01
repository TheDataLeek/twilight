Feature: Ranking algorithm

    As a Mathematician,
    I want an accurate ranking algorithm to sort Twitter users based on influence
    so that I can reference a case model.

    As an average Twitter user,
    I want to be able to see how I rank compared to other users
    so that I can satisfy my idle curiosity.

    As an individual suffering from Obsessive-Compulsive Disorder,
    I want to see users sorted by rank
    so that I can satisfy my urge to keep things neat.

Background: users, their twitter information and a ranked database of a users local network are stored in databases
    Given I am on my user profile

Scenario: Display ranking
    When I click on my ranking page
    Then I should see a list of my followers ranked by influence

Scenario: Sort ranking
    When I click on my ranking
    Then I should see a user with a higher ranking on top
