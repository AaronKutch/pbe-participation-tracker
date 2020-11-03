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

    # Create button and test redirection and button display
    create_available_event('TEST EVENT', 'EVENT LOCATION')

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
    create_available_event('TEST EVENT', 'EVENT LOCATION')
    expect(current_path).to eql('/events')

    # View list of attendees.
    all('a', text: 'Details')[0].click
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
    start_time = ['2020', 'October', '7', '8 PM', '12'] 
    end_time = ['2020', 'October', '7', '8 PM', '13']
    create_custom_event('TEST EVENT', 'TEST LOCATION', start_time, end_time)

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
    start_time = ['2020', 'October', '7', '12 AM', '00'] 
    end_time = [Date.current.year + 1, 'December', '31', '11 PM', '59']
    create_custom_event('TEST EVENT', 'TEST LOCATION', start_time, end_time)

    # sign in as user
    click_on('Logout')
    Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: user_email, password: password)
    common_login(user_email, password)
    expect(page).to have_content('Sign In')
  end
end
