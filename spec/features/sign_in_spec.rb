# frozen_string_literal: true

require 'rails_helper'
require_relative '../common'

admin_email = 'admin@test.com'
password = 'p'

user_email = 'user@test.com'
password = 'p'

RSpec.describe 'Sign in to an event.' do
  it 'Registers the user for an event and displays it on the event page.' do
    admin_create_and_login

    # Create an event.
    click_on('Add new event')
    fill_in('event_title', with: 'TEST EVENT')
    fill_in('event_location', with: 'TEST LOCATION')
    select '12 AM', from: 'event_date_4i'
    select '00', from: 'event_date_5i'
    select '11 PM', from: 'event_end_time_4i'
    select '59', from: 'event_end_time_5i'

    click_on('Submit')
    expect(current_path).to eql('/events')
    expect(page).to have_content('TEST EVENT')

    # Log in as user.
    click_on('Logout')
    Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: user_email, password: password)
    common_login(user_email, password)

    # Sign up for an event.
    all('a', text: 'Sign In')[0].click
    visit('/events')

    # TODO
    # Attempt to sign in to the same event twice.
    # all('a', :text => 'Sign In')[0].click
    # expect(current_path).to eql('/events')
    # expect(page).to have_content('You have already registered for this event.')

    # Sign back in as an admin.
    click_on('Logout')
    common_login(admin_email, password)

    # Show list of attendees of an event.
    all('a', text: 'Details')[0].click
    expect(page).to have_content('Jane Doe')
    expect(page).to have_content(user_email)
  end
end

# Make sure page does not display any users if users have not registered for
# any events.
RSpec.describe 'View list of users registered when no users have registered yet.' do
  it 'Returns an empty set of users.' do
    # Log in as an admin.
    admin_create_and_login

    # Create an event.
    click_on('Add new event')
    fill_in('event_title', with: 'TEST EVENT')
    fill_in('event_location', with: 'TEST LOCATION')
    select '12 AM', from: 'event_date_4i'
    select '00', from: 'event_date_5i'
    select '11 PM', from: 'event_end_time_4i'
    select '59', from: 'event_end_time_5i'
    click_on('Submit')
    expect(current_path).to eql('/events')

    # View list of attendees.
    all('a', text: 'Details')[0].click

    # expect(page).to have_no_content
    expect(page).to have_no_content('@')
    Customer.all.each do |c|
      expect(page).to have_no_content("#{c.first_name} #{c.last_name}")
    end
  end
end

RSpec.describe 'Ensures users are not able to sign in after end_time or before date time.' do
  it 'Hides the Sign In button.' do
    include ActiveSupport::Testing::TimeHelpers
    # Log in as an admin.
    admin_create_and_login

    # Create an event.
    click_on('Add new event')
    fill_in('event_title', with: 'TEST EVENT')
    fill_in('event_location', with: 'TEST LOCATION')

    # fill in date (start time)
    select '2020', from: 'event_date_1i'
    select 'October', from: 'event_date_2i'
    select '7', from: 'event_date_3i'
    select '8 PM', from: 'event_date_4i'
    select '12', from: 'event_date_5i'

    # fill in end_time
    select '2020', from: 'event_end_time_1i'
    select 'October', from: 'event_end_time_2i'
    select '7', from: 'event_end_time_3i'
    select '8 PM', from: 'event_end_time_4i'
    select '13', from: 'event_end_time_5i'
    click_on('Submit')
    expect(current_path).to eql('/events')

    # sign in as user
    click_on('Logout')
    Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: user_email, password: password)
    common_login(user_email, password)

    # change time to after end_time
    travel_to Time.zone.local(2020, 10, 7, 20, 14)
    expect(page).not_to have_content('Sign In')

    # change time to before date time and refresh page
    travel_to Time.zone.local(2020, 10, 7, 20, 11)
    visit current_path
    expect(page).not_to have_content('Sign In')
  end
end

RSpec.describe 'Ensures users are able to sign in within date to end_time time frame.' do
  it 'Hides the Sign In button.' do
    include ActiveSupport::Testing::TimeHelpers
    # Log in as an admin.
    admin_create_and_login

    # freeze_time
    travel_to Time.zone.local(2020, 10, 7, 20, 14)

    # Create an event.
    click_on('Add new event')
    fill_in('event_title', with: 'TEST EVENT')
    fill_in('event_location', with: 'TEST LOCATION')

    # fill in date (start time)
    select '2020', from: 'event_date_1i'
    select 'October', from: 'event_date_2i'
    select '7', from: 'event_date_3i'
    select '8 PM', from: 'event_date_4i'
    select '12', from: 'event_date_5i'

    # fill in end_time
    select '2020', from: 'event_end_time_1i'
    select 'October', from: 'event_end_time_2i'
    select '7', from: 'event_end_time_3i'
    select '8 PM', from: 'event_end_time_4i'
    select '15', from: 'event_end_time_5i'
    click_on('Submit')
    expect(current_path).to eql('/events')

    # sign in as user
    click_on('Logout')
    Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: user_email, password: password)
    common_login(user_email, password)
    expect(page).to have_content('Sign In')
  end
end
