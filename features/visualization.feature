Feature: Visualizations

    As a image enthusiast,
    I want to be able to see visualizations of my social network
    so that I can see pretty pictures.

Background: users, their twitter information and a ranked database of a users local network are stored in databases
    Given I am on the home page

Scenario: Display Visualization
    Then I should see influence as a graph
