require 'rails_helper'
require_relative '../common'

# Make sure that the new event page is visitable.
RSpec.describe 'Visit the new event page' do
  it 'Goes to the new event page.' do
    admin_create_and_login

    click_on('Add new event')
    expect(current_path).to eql('/events/new')
    expect(page).to have_content('Title')
    expect(page).to have_content('Description')
    expect(page).to have_content('Date')
    expect(page).to have_content('Location')
    expect(page).to have_content('Mandatory')
  end
end

# Fill out form contents.
RSpec.describe 'Create a new event.' do
  it 'Displays a new event in the index.' do
    admin_create_and_login

    # Create new event.
    click_on('Add new event')
    fill_in('event_title', with: 'TEST EVENT ONE')
    fill_in('event_location', with: 'TEST LOCATION ONE')
    click_on('Submit')

    # Look for event in the index.
    expect(current_path).to eql('/events')
    expect(page).to have_content('TEST EVENT ONE')
  end
end

# Successfully edit event.
RSpec.describe 'Edit an event.' do
  it 'Changes the name of the created event.' do
    admin_create_and_login

    # Setting up event:
    click_on('Add new event')
    fill_in('event_title', with: 'TEST EVENT ONE')
    fill_in('event_location', with: 'TEST LOCATION ONE')
    click_on('Submit')

    expect(current_path).to eql('/events')
    expect(page).to have_content('TEST EVENT ONE')

    # Editing:
    all('a', text: 'Edit')[0].click
    expect(page).to have_content('Title')
    fill_in('event_title', with: 'EDITED EVENT TITLE')
    click_on('Submit')

    expect(current_path).to eql('/events')
    expect(page).to have_content('EDITED EVENT TITLE')
  end
end

# Attempt to pass a null value into title (a required field). This
# should prevent the user from creating the event and return them
# back to the new event page.
# Only appears to work if js == true, but fails otherwise.
RSpec.describe 'Attempt to make an event title null.' do
  it 'Redirects user back to new event page.' do
    admin_create_and_login

    # Attempt to create a new event.
    visit('/events/new')
    click_on('Submit')

    expect(current_path).to eql('/events')
  end
end

# Attempt to edit an event such that the title now has a null value.
# Similarly to the previous test, it also only appears to work if
# js == true.
RSpec.describe 'Change title to null.' do
  it 'Redirects the user back to the edit page.' do
    admin_create_and_login

    # Edit the title to become null.
    visit('/events/new')
    fill_in('event_title', with: 'TEST EVENT ONE')
    fill_in('event_location', with: 'TEST LOCATION ONE')
    click_on('Submit')

    expect(current_path).to eql('/events')
    all('a', text: 'Edit')[0].click
    fill_in('event_title', with: '')
    click_on('Submit')

    expect(current_path).to eql('/events')
  end
end

# Attempt to delete an event.
RSpec.describe 'Delete an event.' do
  it 'Removes an event from the index.' do
    admin_create_and_login

    # Create the event.
    visit('/events/new')
    fill_in('event_title', with: 'TEST EVENT ONE')
    fill_in('event_location', with: 'TEST LOCATION ONE')
    click_on('Submit')

    expect(current_path).to eql('/events')
    expect(page).to have_content('TEST EVENT ONE')

    # Delete the event.
    all('a', text: 'Delete')[0].click
    expect(current_path).to include('delete')
    click_on('Delete Event')

    # Make sure event is no longer in the index.
    expect(current_path).to eql('/events')
    expect(page).to have_no_content('TEST EVENT ONE')
  end
end

# Show an event.
RSpec.describe 'Show an event.' do
  it 'Displays event details.' do
    admin_create_and_login

    # Create the event.
    visit('/events/new')
    fill_in('event_location', with: 'TEST LOCATION ONE')
    fill_in('event_title', with: 'TEST EVENT ONE')
    click_on('Submit')
    expect(current_path).to eql('/events')

    # Show the event.
    all('a', text: 'Show')[0].click

    expect(page).to have_content('Event name')
    expect(page).to have_content('TEST LOCATION ONE')

    expect(page).to have_content('Location')
    expect(page).to have_content('TEST LOCATION ONE')
  end
end

# Set the date of an event.
RSpec.describe 'Set date of an event.' do
  it 'Shows a different date.' do
    admin_create_and_login

    # Create event.
    visit('/events/new')
    fill_in('event_location', with: 'TEST LOCATION ONE')
    fill_in('event_title', with: 'TEST EVENT ONE')
    select('2024', from: 'event_date_1i')
    select('February', from: 'event_date_2i')
    select('15', from: 'event_date_3i')
    select('17', from: 'event_date_4i')
    select('30', from: 'event_date_5i')
    click_on('Submit')
    expect(current_path).to eql('/events')

    # Show event.
    all('a', text: 'Show')[0].click
    expect(page).to have_content('2024-02-15 17:30:00 UTC')
  end
end

# Create an event, including a description.
RSpec.describe 'Create an event with a description.' do
  it 'Displays the same description specified by the user.' do
    admin_create_and_login

    # Create an event.
    visit('/events/new')
    fill_in('event_title', with: 'Description Test')
    fill_in('event_description', with: 'This is a description test.')
    fill_in('event_location', with: 'Test location.')
    click_on('Submit')
    expect(current_path).to eql('/events')

    # Show the event, verifying that it is showing the correct description.
    all('a', text: 'Show')[0].click
    expect(page).to have_content('Description Test')
    expect(page).to have_content('This is a description test.')
    expect(page).to have_content('Test location')
  end
end

# Return to the home-page by clicking on the PBE logo.
RSpec.describe 'Click on the PBE logo.' do
  it 'Redirects the user back to the events page.' do
    admin_create_and_login

    click_on('Add new event')
    expect(current_path).to eql('/events/new')
    page.first('.mr-auto').click
    expect(current_path).to eql('/events')
  end
end

# Register for a new event, at which point the sign-in for that
# event will no longer be visible.
# RSpec.describe 'Register for a new event.' do
#  it 'Removes the sign-in button from view.' do
#    admin_create_and_login()
#
#    user_email = 'user@test.com'
#    user_password = 'p'
#    Customer.create(:first_name => 'Jane', :last_name => 'Doe', :role => 'user', :email => user_email, :password => user_password)

# Create an event.
#    click_on('Add new event')
#    expect(current_path).to eql('/events/new')
#    fill_in('event_title', :with => 'Event #1')
#    fill_in('event_location', :with => 'Location #1')
#    click_on('Submit')
#    expect(current_path).to eql('/events')

# Log back in as a user.
#    click_on('Logout')
#    click_on('Login')
#    common_login(user_email, user_password)

# Sign into Event #1.
#    all('a', :text => 'Sign In')[0].click
#    visit('/events')

#  end
# end

# Full test of modifying each field.
RSpec.describe 'Create a new event with each field modified from defaults.' do
  it 'Displays the contents of each field.' do
    admin_create_and_login

    # Create an event.
    click_on('Add new event')
    expect(current_path).to eql('/events/new')
    fill_in('event_title', with: 'Full test A')
    fill_in('event_description', with: 'Event description A')
    select('2021', from: 'event_date_1i')
    select('July', from: 'event_date_2i')
    select('9', from: 'event_date_3i')
    select('19', from: 'event_date_4i')
    select('00', from: 'event_date_5i')
    fill_in('event_location', with: 'Event location A')
    uncheck('event_mandatory')
    click_on('Submit')
    expect(current_path).to eql('/events')

    # Show event, verifying that all information displayed is correct.
    all('a', text: 'Show')[0].click
    expect(page).to have_content('Full test A') # Title
    expect(page).to have_content('Event description A') # Description
    expect(page).to have_content('2021-07-09 19:00:00 UTC') # Time
    expect(page).to have_content('Event location A') # Location
    expect(page).to have_content('false') # Mandatory
  end
end
