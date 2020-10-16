# frozen_string_literal: true

require 'rails_helper'
require_relative '../common'

# Attempt to access events index without logging in.
RSpec.describe 'Attempt to access events index without logging in.' do
  it 'Redirects the user back to login page.' do
    visit('/')
    visit('/events/1/edit')
    expect(current_path).to eql('/access/login')
  end
end

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

# Attempt to create an event with a title that is more
# than 50 characters long.
RSpec.describe 'Create a new event with a title that is too long.' do
  it 'Redirects the user to /events page.' do
    admin_create_and_login

    # Create new event.
    click_on('Add new event')
    @x = ''
    (0..100).each do |i|
      @x += i.to_s
    end
    fill_in('event_title', with: @x)
    fill_in('event_location', with: @x)
    click_on('Submit')
    expect(current_path).to eql('/events')
    expect(page).to have_no_content(@x)
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

# Attempt to edit an event that does not exist.
RSpec.describe 'Edit a non-existant event.' do
  it 'Redirects user back to /events page.' do
    admin_create_and_login

    # Attempt to edit event when none has been created.
    visit('/events/500/edit')
    expect(current_path).to eql('/events')
  end
end

# Attempt to edit an event without admin permissions.
RSpec.describe 'Edit a page without admin permissions.' do
  it 'Redirects user back to /users path.' do
    @c = Customer.create(first_name: 'Jane', last_name: 'Doe', email: 'js@email.com', role: 'user', password: 'p')
    common_login('js@email.com', 'p')
    visit("/users/#{@c.id}/edit")
    expect(current_path).to eql('/users')
    expect(page).to have_content('You do not have admin permissions.')
  end
end

# Attempt to perform edit, delete operations without admin permissions.
RSpec.describe 'Edit/delete a page without admin permissions.' do
  it 'Redirects user back to /users path.' do
    @c = Customer.create(first_name: 'Jane', last_name: 'Doe', email: 'js@email.com', role: 'user', password: 'p')
    common_login('js@email.com', 'p')

    visit("/events/#{@c.id}/edit")
    expect(current_path).to eql('/events')
    expect(page).to have_content('You don\'t have permission to do that')

    visit("/events/#{@c.id}/delete")
    expect(current_path).to eql('/events')
    expect(page).to have_content('You don\'t have permission to do that')

    visit('/events/new')
    expect(current_path).to eql('/events')
    expect(page).to have_content('You don\'t have permission to do that')
  end
end

# Attempt to delete an event without admin permissions.
RSpec.describe 'Delete a page without admin permissions.' do
  it 'Redirects user back to /users path.' do
    @c = Customer.create(first_name: 'Jane', last_name: 'Doe', email: 'js@email.com', role: 'user', password: 'p')
    common_login('js@email.com', 'p')
    visit("/users/#{@c.id}/delete")
    expect(page).to have_content('You do not have admin permissions.')
    expect(current_path).to eql('/users')
  end
end

# Attempt to edit an event to have a title that is
# more than 50 characters long.
RSpec.describe 'Edit an event to have a title that is too long.' do
  it 'Redirects user back to /events path.' do
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
    @x = ''
    (0..100).each do |i|
      @x += i.to_s
    end
    fill_in('event_title', with: @x)
    click_on('Submit')

    expect(current_path).to eql('/events')
    expect(page).to have_content('TEST EVENT ONE')
    expect(page).to have_no_content(@x)
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

# Attempt to delete an event that has already been deleted.
RSpec.describe 'Delete an event that has already been deleted.' do
  it 'Redirects the user back to the /events path.' do
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

    # Destroy the event from database.
    @e = Event.first
    @e.destroy

    # Attempt to delete the event again.
    click_on('Delete Event')
    expect(current_path).to eql('/events')
  end
end

# Attempt to delete an event that does not exist.
RSpec.describe 'Delete an event that does not exist.' do
  it 'Redirects user back to /events path.' do
    admin_create_and_login

    # Attempt to access delete page that does not exist.
    visit('/events/500/delete')
    expect(current_path).to eql('/events')
  end
end

# Details an event.
RSpec.describe 'Details an event.' do
  it 'Displays event details.' do
    admin_create_and_login

    # Create the event.
    visit('/events/new')
    fill_in('event_location', with: 'TEST LOCATION ONE')
    fill_in('event_title', with: 'TEST EVENT ONE')
    click_on('Submit')
    expect(current_path).to eql('/events')

    # Details the event.
    all('a', text: 'Details')[0].click

    expect(page).to have_content('Event name')
    expect(page).to have_content('TEST LOCATION ONE')

    expect(page).to have_content('Location')
    expect(page).to have_content('TEST LOCATION ONE')
  end
end

# Details of an event which no longer exists.
RSpec.describe 'Details of a non-existant event.' do
  it 'Redirects user back to /events page.' do
    admin_create_and_login

    # Attempt to access details of an event before creating one.
    visit('/events/1')
    expect(current_path).to eql('/events')
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
    select(Date.today.year, from: 'event_date_1i')
    select('February', from: 'event_date_2i')
    select('1', from: 'event_date_3i')
    select('01 PM', from: 'event_date_4i')
    select('30', from: 'event_date_5i')
    click_on('Submit')
    expect(current_path).to eql('/events')

    # Details event
    all('a', text: 'Details')[0].click
    expect(page).to have_content("Feb 1, #{Date.today.year}, 1:30 pm")
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
    all('a', text: 'Details')[0].click
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
RSpec.describe 'Register for a new event.' do
  it 'Removes the sign-in button from view.' do
    admin_create_and_login
    user_email = 'user@test.com'
    user_password = 'p'
    Customer.create(
      first_name: 'Jane',
      last_name: 'Doe',
      role: 'user',
      email: user_email,
      password: user_password
    )

    # Create an event.
    click_on('Add new event')
    expect(current_path).to eql('/events/new')
    fill_in('event_title', with: 'Event #1')
    fill_in('event_location', with: 'Location #1')

    select 'January', from: 'event_date_2i'
    select '1', from: 'event_date_3i'
    select '2020', from: 'event_date_1i'
    select '12 AM', from: 'event_date_4i'
    select '00', from: 'event_date_5i'

    select 'December', from: 'event_end_time_2i'
    select '31', from: 'event_end_time_3i'
    select '2020', from: 'event_end_time_1i'
    select '11 PM', from: 'event_end_time_4i'
    select '59', from: 'event_end_time_5i'

    click_on('Submit')
    expect(current_path).to eql('/events')

    # Log back in as a user.
    click_on('Logout')
    common_login(user_email, user_password)

    # Sign into Event #1.
    all('a', text: 'Sign In')[0].click
    visit('/events')
  end
end

# Register for an event that has already been
# registered for.
RSpec.describe 'Register for an event again.' do
  it 'Removes the sign-in button from view.' do
    admin_create_and_login
    user_email = 'user@test.com'
    user_password = 'p'
    Customer.create(
      first_name: 'Jane',
      last_name: 'Doe',
      role: 'user',
      email: user_email,
      password: user_password
    )

    # Create an event.
    click_on('Add new event')
    expect(current_path).to eql('/events/new')
    fill_in('event_title', with: 'Event #1')
    fill_in('event_location', with: 'Location #1')

    select 'January', from: 'event_date_2i'
    select '1', from: 'event_date_3i'
    select '2020', from: 'event_date_1i'
    select '12 AM', from: 'event_date_4i'
    select '00', from: 'event_date_5i'

    select 'December', from: 'event_end_time_2i'
    select '31', from: 'event_end_time_3i'
    select '2020', from: 'event_end_time_1i'
    select '11 PM', from: 'event_end_time_4i'
    select '59', from: 'event_end_time_5i'

    click_on('Submit')
    expect(current_path).to eql('/events')

    # Log back in as a user.
    click_on('Logout')
    common_login(user_email, user_password)

    # Sign into Event #1.
    all('a', text: 'Sign In')[0].click
    visit('/events')

    # Sign in again.
    all('a', text: 'Sign In')[0].click
    expect(page).to have_content('You have already registered for this event.')
  end
end

# Full test of modifying each field.
RSpec.describe 'Create a new event with each field modified from defaults.' do
  it 'Displays the contents of each field.' do
    admin_create_and_login

    # Create an event.
    click_on('Add new event')
    expect(current_path).to eql('/events/new')
    fill_in('event_title', with: 'Full test A')
    fill_in('event_description', with: 'Event description A')
    select(Date.today.year, from: 'event_date_1i')
    select('July', from: 'event_date_2i')
    select('9', from: 'event_date_3i')
    select('7 PM', from: 'event_date_4i')
    select('00', from: 'event_date_5i')
    fill_in('event_location', with: 'Event location A')
    uncheck('event_mandatory')
    click_on('Submit')
    expect(current_path).to eql('/events')

    # Show event, verifying that all information displayed is correct.
    all('a', text: 'Details')[0].click
    expect(page).to have_content('Full test A') # Title
    expect(page).to have_content('Event description A') # Description
    expect(page).to have_content("Jul 9, #{Date.today.year}, 7:00 pm") # Time
    expect(page).to have_content('Event location A') # Location
    expect(page).to have_content('false') # Mandatory
  end
end

# Revoke attendance of a user.
RSpec.describe 'Revoke attendance for a user.' do
  it 'The user will no longer be signed in for that event.' do
    admin_create_and_login
    user_email = 'user@test.com'
    user_password = 'p'
    Customer.create(
      first_name: 'Jane',
      last_name: 'Doe',
      role: 'user',
      email: user_email,
      password: user_password
    )

    # Create an event.
    click_on('Add new event')
    expect(current_path).to eql('/events/new')
    fill_in('event_title', with: 'Event #1')
    fill_in('event_location', with: 'Location #1')

    select 'January', from: 'event_date_2i'
    select '1', from: 'event_date_3i'
    select '2020', from: 'event_date_1i'
    select '12 AM', from: 'event_date_4i'
    select '00', from: 'event_date_5i'

    select 'December', from: 'event_end_time_2i'
    select '31', from: 'event_end_time_3i'
    select '2020', from: 'event_end_time_1i'
    select '11 PM', from: 'event_end_time_4i'
    select '59', from: 'event_end_time_5i'

    click_on('Submit')
    expect(current_path).to eql('/events')

    # Log back in as a user.
    click_on('Logout')
    common_login(user_email, user_password)

    # Sign into Event #1.
    all('a', text: 'Sign In')[0].click
    visit('/events')

    # Log back out and login as admin.
    click_on('Logout')
    common_login('admin@test.com', 'p')
    all('a', text: 'Details')[0].click
    expect(page).to have_content('Jane Doe')
    click_on('Revoke Sign In')
    visit('/events')

    # Check if user is still signed in.
    expect(page).to have_no_content('Jane Doe')
  end
end

# Attempt to revoke attendance for a user that does not exist.
RSpec.describe 'Revoke attendance for a non-existant user.' do
  it 'Returns the user to the /events path.' do
  end
end

# Manually add attendance.
RSpec.describe 'Manually add attendance.' do
  it 'Adds event to attendance list and redirects user.' do
    admin_create_and_login
    
    # Create a customer with role 'user.'
    Customer.create(
      first_name: 'Jane',
      last_name: 'Doe',
      email: 'jd@tamu.edu',
      role: 'user',
      password: 'p'
    )
    
    # Create an event.
    Event.create(
      title: 'TEST EVENT',
      description: 'This is an example event.',
      date: '2020-01-01 00:00:00',
      location: 'TEST LOCATION',
      mandatory: true,
      end_time: '2021-02-01 00:00:00',
    )
    
    # Access event details page.
    visit('/events')
    expect(page).to have_content('TEST EVENT')
    all('a', text: 'Details')[0].click
    expect(current_path).to eql('/events/' + Event.first.id.to_s)
    
    # Check for user Jane Doe in manual addition list.
    manual_add_list = find(:css, '#manual_add_list')
    expect(manual_add_list).to have_content('Jane Doe')
    all('a', text: 'Add Sign In')[0].click
    
    visit('/events/' + Event.first.id.to_s)
    manual_add_list = find(:css, '#manual_add_list')
    expect(manual_add_list).to have_no_content('Jane Doe')
    
  end
end

# Attempt to manually add a user to an event that no longer exists.
RSpec.describe 'Manually add attendance to a non-existant event.' do
  it 'Alerts the user and redirects to /events path.' do
    admin_create_and_login
    
    # Create a customer with role 'user.'
    Customer.create(
      first_name: 'Jane',
      last_name: 'Doe',
      email: 'jd@tamu.edu',
      role: 'user',
      password: 'p'
    )
    
    # Create an event.
    Event.create(
      title: 'TEST EVENT',
      description: 'This is an example event.',
      date: '2020-01-01 00:00:00',
      location: 'TEST LOCATION',
      mandatory: true,
      end_time: '2021-02-01 00:00:00',
    )
    
    # Access event details page.
    visit('/events')
    expect(page).to have_content('TEST EVENT')
    all('a', text: 'Details')[0].click
    expect(current_path).to eql('/events/' + Event.first.id.to_s)
    
    # Delete the event from the database.
    Event.first.destroy
    
    # Attempt to add the user to the event.
    all('a', text: 'Add Sign In')[0].click
    expect(current_path).to eql('/events')
    
  end
end

# Attempt to add a user to an event where that user no longer exists.
RSpec.describe 'Manually add attendance for a non-existant user.' do
  it 'Alerts the user and redirects to /event/<id> path.' do
    admin_create_and_login
    
    # Create a customer with role 'user.'
    Customer.create(
      first_name: 'Jane',
      last_name: 'Doe',
      email: 'jd@tamu.edu',
      role: 'user',
      password: 'p'
    )
    
    # Create an event.
    Event.create(
      title: 'TEST EVENT',
      description: 'This is an example event.',
      date: '2020-01-01 00:00:00',
      location: 'TEST LOCATION',
      mandatory: true,
      end_time: '2021-02-01 00:00:00',
    )
    
    # Access event details page.
    visit('/events')
    expect(page).to have_content('TEST EVENT')
    all('a', text: 'Details')[0].click
    expect(current_path).to eql('/events/' + Event.first.id.to_s)
    
    # Delete the user from the database.
    Customer.second.destroy
    
    # Attempt to add the user to the event.
    all('a', text: 'Add Sign In')[0].click
    expect(current_path).to eql('/events/' + Event.first.id.to_s)
  end
end
