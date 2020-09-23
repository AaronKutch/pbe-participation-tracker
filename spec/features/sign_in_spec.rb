require 'rails_helper'

admin_email = 'admin@example.com'
admin_password = 'p'

user_email = 'user@example.com'
user_password = 'p'

RSpec.describe 'Sign in to an event.', js: true do
  it 'Registers the user for an event and displays it on the event page.' do
    Customer.create(:first_name => 'John', :last_name => 'Smith', :role => 'admin', :email => admin_email, :password => admin_password)
    Customer.create(:first_name => 'Jane', :last_name => 'Doe', :role => 'user', :email => user_email, :password => user_password)
    
    # Create an event.
    visit('/')
    click_on('Login')
    fill_in('email', :with => admin_email)
    fill_in('password', :with => admin_password)
    click_on('Log In')
    expect(current_path).to eql('/events')

    # Create an event.
    click_on('Add new event')
    fill_in('event_title', :with => 'TEST EVENT')
    fill_in('event_location', :with => 'TEST LOCATION')
    click_on('Submit')
    expect(current_path).to eql('/events')

    # Log in as user.
    click_on('Logout')
    click_on('Login')
    fill_in('email', :with => user_email)
    fill_in('password', :with => user_password)
    click_on('Log In')
    expect(current_path).to eql('/events')

    # Sign up for an event.
    all('a', :text => 'Sign In')[0].click
    expect(current_path).to eql('/events')

    # Sign back in as an admin.
    click_on('Logout')
    click_on('Login')
    fill_in('email', :with => admin_email)
    fill_in('password', :with => admin_password)
    click_on('Log In')
    expect(current_path).to eql('/events')

    # Show list of attendees of an event.
    all('a', :text => 'Show')[0].click
    expect(page).to have_content('Jane Doe')
    expect(page).to have_content(user_email)
  end
end
    
