# frozen_string_literal: true

require 'rails_helper'
require_relative '../common'

RSpec.describe 'User CRUD features' do
  let!(:admin_email) { 'a@email.com' }
  let!(:admin_password) { 'p' }
  let!(:user_email) { 'u@email.com' }
  let!(:user_password) { 'p' }

  before :each do
    Customer.create(first_name: 'John', last_name: 'Smith', role: 'admin', email: 'a@email.com', password: 'p')
    Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: 'u@email.com', password: 'p')
    visit(root_path)
    common_login(admin_email, admin_password)
  end

  # View list of users.
  describe 'when 2 users are added' do
    it 'it displays user information on /users page.' do
      visit(users_path)

      # Check for admin information.
      expect(page).to have_content('John Smith')
      expect(page).to have_content(admin_email)
      expect(page).to have_css('i[title="admin"]')

      # Check for user information.
      expect(page).to have_content('Jane Doe')
      expect(page).to have_content(user_email)
      expect(page).to have_css('i[title="user"]')
    end
  end

  # Show the list of events that a user has attended.
  describe 'when a user has signed in to events' do
    it 'shows the user\'s attended events' do
      visit(events_path)

      # Create an event to attend.
      click_on('Add new event')
      expect(current_path).to eql(new_event_path)
      fill_in('event_title', with: 'Event 1')
      fill_in('event_location', with: 'Location 1')
      select('January', from: 'event_date_2i')
      select(Date.today.day, from: 'event_date_3i')
      select('12 AM', from: 'event_date_4i')
      select('00', from: 'event_date_5i')
      select(Date.today.year + 1, from: 'event_end_time_1i')
      select('11 PM', from: 'event_end_time_4i')
      select('59', from: 'event_end_time_5i')
      click_on('Submit')
      visit(events_path)
      expect(page).to have_content('Event 1')

      # Log back in as a user.
      visit(root_path)
      common_login(user_email, user_password)

      # Sign in to the event.
      all('a', text: 'Sign In')[0].click

      # Logout and log back in as admin.
      visit(root_path)
      common_login(admin_email, admin_password)

      # Verify that event appears in list of events attended.
      all('a', text: 'Details')[0].click
      expect(page).to have_content('Event 1')

      # Show list of events that user has attended.
      visit(users_path)
      all('a', text: 'Details')[0].click
      @curr_path = current_path.to_s
      expect(page).to have_content('Member Info')

      # Visit user page directly.
      visit(@curr_path)
      expect(page).to have_content('Events Attended')
    end
  end

  # Promote a user to admin.
  describe 'when a user is promoted to admin' do
    it 'changes the user to an admin on the users page' do
      visit(users_path)

      # Expect to have both admins and users.
      expect(page).to have_css('i[title="user"]')
      expect(page).to have_css('i[title="admin"]')

      # Update the user to an admin.
      all('a', text: 'Update Role')[0].click
      expect(current_path).to include('edit')
      select('admin', from: 'customer_role')
      click_on('Submit')

      # Make sure that there are no more admin customers left.
      visit(users_path)
      expect(page).to have_no_content('user')
    end
  end

  # Attempt to show a user that does not exist.
  describe 'when a nonexistant user is selected' do
    it 'redirects back to /users path' do
      # Attempt to show a user with an invalid ID.
      visit('/users/500')
      expect(page).to have_no_content('User Information')
    end
  end

  # Attempt to promote a user that does not exist.
  describe 'when a user that doesn\'t exist is promoted' do
    it 'redirects back to /users path.' do
      # Attempt to edit a user with an invalid ID.
      visit('/users/500/edit')
      expect(page).to have_no_content('Update User Role')
      expect(current_path).to eql(users_path)
    end
  end

  # Attempt to delete a user that does not exist.
  describe 'when a nonexistant user is deleted' do
    it 'Redirects back to /users path' do
      # Attempt to edit a user with an invalid ID.
      visit('/users/500/delete')
      expect(page).to have_no_content('Delete User')
    end
  end

  # Attempt to delete a user that has already been deleted.
  describe 'when a users is deleted twice' do
    it 'redirects back to /users path' do
      visit(users_path)

      # Delete a user.
      all('a', text: 'Delete')[0].click
      @curr_path = current_path
      click_on('Delete User')
      visit(users_path)

      # Attempt to delete the user again.
      visit(@curr_path)
      expect(page).to have_no_content('Delete User')
      expect(current_path).to eql(users_path)
    end
  end

  # Attempt to destroy a user that has already been deleted.
  describe 'when a user is destroyed twice' do
    it 'redirects back to /users path.' do
      @c = Customer.second
      visit(users_path)

      # Attempt to delete user.
      all('a', text: 'Delete')[0].click

      @c.destroy
      click_on('Delete User')
      expect(current_path).to eql(users_path)
    end
  end

  # Attempt to update a user that has already been deleted.
  describe 'when a deleted user is updated' do
    it 'redirects back to /users path.' do
      @c = Customer.second
      visit(users_path)

      # Attempt to update user.
      all('a', text: 'Update Role')[1].click

      @c.destroy
      click_on('Submit')
    end
  end

  describe 'when a deleted user is shown' do
    it 'redirects back to /users path' do
      @c = Customer.second
      visit(users_path)

      # Delete a user.
      all('a', text: 'Delete')[0].click
      click_on('Delete User')
      visit(users_path)

      # Attempt to show the user's information.
      visit("/users/#{@c.id}")
      expect(page).to have_no_content('User Information')
      expect(current_path).to eql(users_path)
    end
  end

  # Delete a user.
  describe 'when a user is deleted' do
    it 'removes that user from the users page' do
      visit(users_path)

      # Expect to have both admins and users.
      expect(page).to have_css('i[title="user"]')
      expect(page).to have_css('i[title="admin"]')

      # Delete the user.
      all('a', text: 'Delete')[0].click
      expect(current_path).to include('/delete')
      click_on('Delete User')

      # Expect for the user to have been removed.
      visit(users_path)
      expect(current_path).to eql(users_path)
      expect(page).to have_no_content('Jane Doe')
      expect(page).to have_no_content('user')
    end
  end

  # Attempt to view the /users page as a non-admin.
  describe 'when /users is viewed as a non-admin' do
    it 'redirects user back to /events page' do
      # Log in as user.
      visit(root_path)
      common_login(user_email, user_password)

      # Attempt to view the /users page.
      visit(users_path)
      expect(page).to have_no_content('Current Members')
    end
  end
end
