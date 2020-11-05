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

    # Create button and test redirection and button display
    create_available_event('TEST EVENT', 'EVENT LOCATION')

    # Log in as user.
    click_on('Logout')
    Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: user_email, password: password)
    common_login(user_email, password)

    # Go to details page and use sign-in button.
    all('a', text: 'Details')[0].click
    click_on('Sign In')

    # refresh page
    visit(current_path)

    # Log in as admin.
    visit('/')
    common_login(admin_email, password)
    all('a', text: 'Details')[0].click
    all('a', text: 'Revoke Sign In')[0].click
    visit('/events')

    # Log back in as user.
    visit('/')
    common_login(user_email, password)

    # Go to events page.
    visit('/events')
    Customer.second.events << Event.first

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

    # create event at specific time
    start_time = ['2020', 'October', '7', '8 PM', '12']
    end_time = ['2020', 'October', '7', '8 PM', '13']
    create_custom_event('TEST EVENT', 'TEST LOCATION', start_time, end_time)
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
  it 'Shows Sign In button on display page.' do
    include ActiveSupport::Testing::TimeHelpers
    # Log in as an admin.
    admin_create_and_login

    # freeze_time
    travel_to Time.zone.local(2020, 10, 7, 20, 14)

    # Create an event.
    start_time = ['2020', 'October', '7', '12 AM', '00']
    end_time = [Date.current.year + 1, 'December', '31', '11 PM', '59']
    create_custom_event('TEST EVENT', 'TEST LOCATION', start_time, end_time)
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
