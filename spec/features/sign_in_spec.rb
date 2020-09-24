require 'rails_helper'
require_relative '../common'

admin_email = 'admin@test.com'
password = 'p'

user_email = 'user@test.com'
password = 'p'

RSpec.describe 'Sign in to an event.' do
  it 'Registers the user for an event and displays it on the event page.' do

    admin_create_and_login()

    # Create an event.
    click_on('Add new event')
    fill_in('event_title', :with => 'TEST EVENT')
    fill_in('event_location', :with => 'TEST LOCATION')
    click_on('Submit')
    expect(current_path).to eql('/events')
    expect(page).to have_content('TEST EVENT')

    # Log in as user.
    click_on('Logout')
    Customer.create(:first_name => 'Jane', :last_name => 'Doe', :role => 'user', :email => user_email, :password => password)
    common_login(user_email, password)

    # Sign up for an event.
    all('a', :text => 'Sign In')[0].click
    visit('/events')

    # TODO
    # Attempt to sign in to the same event twice.
    #all('a', :text => 'Sign In')[0].click
    #expect(current_path).to eql('/events')
    #expect(page).to have_content('You have already registered for this event.')

    # Sign back in as an admin.
    click_on('Logout')
    common_login(admin_email, password)

    # Show list of attendees of an event.
    all('a', :text => 'Show')[0].click
    expect(page).to have_content('Jane Doe')
    expect(page).to have_content(user_email)
  end
end

# Make sure page does not display any users if users have not registered for
# any events.
RSpec.describe 'View list of users registered when no users have registered yet.' do
  it 'Returns an empty set of users.' do

    # Log in as an admin.
    admin_create_and_login()

    # Create an event.
    click_on('Add new event')
    fill_in('event_title', :with => 'TEST EVENT')
    fill_in('event_location', :with => 'TEST LOCATION')
    click_on('Submit')
    expect(current_path).to eql('/events')

    # View list of attendees.
    all('a', :text => 'Show')[0].click

    #expect(page).to have_no_content
    expect(page).to have_no_content('@')
    for c in Customer.all
      expect(page).to have_no_content(c.first_name.to_s + ' ' + c.last_name.to_s)
    end
  end
end




