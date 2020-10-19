# frozen_string_literal: true

require 'rails_helper'
require_relative '../common'

admin_email = 'admin@test.com'
password = 'p'

user_email = 'user@test.com'
password = 'p'

RSpec.describe 'Sign in via details page.' do
  it 'Registers the user for an event and displays it on the event page.' do
    admin_create_and_login

    # Create an event.
    click_on('Add new event')
    fill_in('event_title', with: 'TEST EVENT')
    fill_in('event_location', with: 'TEST LOCATION')
    select 'January', from: 'event_date_2i'
    select Date.today.day, from: 'event_date_3i'
    select '12 AM', from: 'event_date_4i'
    select '00', from: 'event_date_5i'
    select Date.today.year + 1, from: 'event_end_time_1i'
    select '11 PM', from: 'event_end_time_4i'
    select '59', from: 'event_end_time_5i'

    click_on('Submit')
    expect(current_path).to eql('/events')
    expect(page).to have_content('TEST EVENT')

    # Log in as user.
    click_on('Logout')
    Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: user_email, password: password)
    common_login(user_email, password)

    # Go to details page and use sign-in button.
    all('a', text: 'Details')[0].click
    click_on('Sign In')
    
    # refresh page
    visit(current_path)

    # check for handling attempts to sign into registered events
    click_on('Sign In')
    expect(page).to have_content('You have already registered for this event.')
    expect(current_path).to eql('/events')

    # Sign back in as an admin.
    click_on('Logout')
    common_login(admin_email, password)

    # Show list of attendees of an event.
    all('a', text: 'Details')[0].click
    expect(page).to have_content('Jane Doe')
    expect(page).to have_content(user_email)
  end
end

RSpec.describe 'Ensures users are not able to sign in after end_time or before date time.' do
  it 'Indicates unavailable sign-in button on details page.' do
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

    # sign in as user and navigate to details page
    click_on('Logout')
    Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: user_email, password: password)
    common_login(user_email, password)
    all('a', text: 'Details')[0].click

    # change time to after end_time
    travel_to Time.zone.local(2020, 10, 7, 20, 14)
    expect(page).to have_content('Unavailable')

    # change time to before date time and refresh page
    travel_to Time.zone.local(2020, 10, 7, 20, 11)
    visit current_path
    expect(page).to have_content('Unavailable')
  end
end

RSpec.describe 'Ensures users are able to sign in within date to end_time time frame.' do
  it 'Shows Sign In button on dispaly page.' do
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
    select '12 AM', from: 'event_date_4i'
    select '00', from: 'event_date_5i'

    # fill in end_time
    select Date.current.year + 1, from: 'event_end_time_1i'
    select '11 PM', from: 'event_end_time_4i'
    select '59', from: 'event_end_time_5i'
    click_on('Submit')
    expect(current_path).to eql('/events')

    # sign in as user and register for event via details page
    click_on('Logout')
    Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: user_email, password: password)
    common_login(user_email, password)
    all('a', text: 'Details')[0].click
    click_on('Sign In')

    # verify registration through admin account
    visit('/events')
    click_on('Logout')
    common_login(admin_email, password)

    # Show list of attendees of an event.
    all('a', text: 'Details')[0].click
    expect(page).to have_content('Jane Doe')
    expect(page).to have_content(user_email)
  end
end
