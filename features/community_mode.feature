@organizations
Feature: When I use Teambox community version, there is only one organization

  Background:
    Given I am using the community version
    And the database is empty

  Scenario: I am asked to configure the deployment
    When I go to the login page
    Then I should see "Configure your site"

  Scenario: I create the first account on the system
    When I go to the login page
    And I follow "Create your admin account now"
    Then I should not see "If you already have an account"
    And I should not see "log in"
    And I should not see "retrieve your password"
    When I fill in the following:
      | Username         | mislav                    |
      | First name       | Mislav                    |
      | Last name        | Marohnić                  |
      | Email            | mislav@fuckingawesome.com |
      | Password         | dragons                   |
      | Confirm password | dragons                   |
    And I press "Create account"
    Then I should see "Confirm your email"
    And "mislav@fuckingawesome.com" should receive an email
    When I open the email
    Then I should see "Hey, Mislav Marohnić!" in the email body
    When I follow "Log into Teambox now!" in the email
    Then I should see "Welcome"

  Scenario: I create a user account, but without an organization the system is not fully configured
    Given I am logged in as mislav
    And I log out
    Then I should see "The configuration didn't finish. Please log in as Mislav Marohnić and complete it by creating an organization."

  Scenario: I can't create a second user account without an invitation for it
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    And I log out
    When I go to the signup page
    Then I should see "Public signups are not allowed on this system."

  Scenario: Users can sign up with an invitation
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    And "mislav" is the owner of the project "Ruby Rockstars"
    And "mislav" sent an invitation to "ed_bloom@spectre.com" for the project "Ruby Rockstars"
    And I log out
    When "ed_bloom@spectre.com" opens the email with subject "Ruby Rockstars"
    And they should see "Mislav Marohnić wants to collaborate with you on Teambox" in the email body
    And I should see "Ruby Rockstars" in the email body
    And I follow "Accept the invitation to start collaborating" in the email
    When I fill in "Username" with "bigfish"
    And I fill in "First name" with "Edward"
    And I fill in "Last name" with "Bloom"
    And I fill in "Password" with "tellastory"
    And I fill in "Confirm password" with "tellastory"
    And I press "Create account"
    Then I should see "Ruby Rockstars"
    And I should see "Thanks for signing up!"
    When I go to the people page of the "Ruby Rockstars" project
    Then I should see "Edward Bloom"
    And I should see "Mislav Marohnić"

  Scenario: I create a user account and a project (with its organization), and I can log in through the branded page
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    When I log out
    Then I should see "Private area"
    When I fill in "login" with "mislav"
    And I fill in "password" with "wrong"
    And I press "Login"
    Then I should see "Couldn't log you in as mislav"
    When I fill in "login" with "mislav"
    And I fill in "password" with "dragons"
    And I press "Login"
    Then I should see "All Projects"
    And I should see "Organization"
    But I should not see "Organizations"

  Scenario: I can't create a second organization
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    And "mislav" is an administrator in the organization called "ACME"
    When I go to the organizations page
    Then I should see "The community version doesn't support multiple organizations"
    When I go to the new organization page
    Then I should see "The community version doesn't support multiple organizations"

  Scenario: I create a second project in the organization as an administrator
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    And "mislav" is an administrator in the organization called "ACME"
    When I go to the home page
    And I follow "+ New project" within "#projects_tab_list"
    And I fill in "Name" with "Another project"
    And I press "Create project and start collaborating"
    Then I should see "Ruby Rockstars" within "#projects_tab_list"
    Then I should see "Another project" within "#projects_tab_list"

  Scenario: I create a second project in the organization as a participant
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    And "mislav" is a participant in the organization called "ACME"
    When I go to the home page
    And I follow "+ New project" within "#projects_tab_list"
    And I fill in "Name" with "Another project"
    And I press "Create project and start collaborating"
    Then I should see "Ruby Rockstars" within "#projects_tab_list"
    Then I should see "Another project" within "#projects_tab_list"

  Scenario: I can't create a project if I'm not part of the organization
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    And "mislav" is not a member of the organization called "ACME"
    And I go to the home page
    Then I should not see "+ New project" within "#projects_tab_list"
    And I should not see "New project"
    When I go to the new project page
    Then I should see "You're not authorized to create projects on this organization."

  Scenario: I'm asked to customize my deployment
    Given I am logged in as mislav
    And I am currently in the project ruby_rockstars
    And "mislav" is an administrator in the organization called "ACME"
    And I go to the home page
    Then I should see "configure your organization"
    When I follow "Click here"
    Then I should see "Introduce some HTML code for your main site to configure your site"
    When I fill in "organization_description" with "<h1>TITLE</h1>"
    And I press "Save changes"
    Then I should not see "Introduce some HTML code for your main site to configure your site"
    When I log out
    Then I should see "TITLE" within "h1"
