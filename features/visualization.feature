Feature: Visualizations

    As a image enthusiast,
    I want to be able to see visualizations of my social network
    so that I can see pretty pictures.

Background: users, their twitter information and a ranked database of a users local network are stored in databases
    Given I am on my user profile

Scenario: Display Visualization
    When I click on my visualization
    Then I should see my influence as a graph

