require 'rails_helper'
require_relative '../common'

$admin_email = 'a@email.com'
$admin_password = 'p'

$user_email = 'u@email.com'
$user_password = 'p'

def create_admin
  return Customer.create(first_name: 'John', last_name: 'Smith', role: 'admin', email: $admin_email, password: $admin_password)
end

def create_user
  return Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: $user_email, password: $user_password)
end

# View list of users.
RSpec.describe 'Add 2 users.' do
  it 'Displays user information on /users page.' do

    # Create admin and user customers.
    create_admin
    create_user

    # Log in.    
    visit('/')
    common_login($admin_email, $admin_password)
    visit('/users')

    # Check for admin information.
    expect(page).to have_content('John Smith')
    expect(page).to have_content($admin_email)
    expect(page).to have_content('admin')

    # Check for user information.
    expect(page).to have_content('Jane Doe')
    expect(page).to have_content($user_email)
    expect(page).to have_content('user')

  end
end

# Show the list of events that a user has attended.
RSpec.describe 'Display list of events that a user has attended.' do
  it 'Shows event that user has attended.' do
    
    # Create admin and user customers.
    create_admin
    create_user

    # Log in as an admin.
    visit('/')
    common_login($admin_email, $admin_password)
    visit('/events')

    # Create an event to attend.
    click_on('Add new event')
    expect(current_path).to eql('/events/new')
    fill_in('event_title', with: 'Event 1')
    fill_in('event_location', with: 'Location 1')
    click_on('Submit')
    visit('/events')
    expect(page).to have_content('Event 1')

    # Log back in as a user.
    visit('/')
    common_login($user_email, $user_password)
    
    # Sign in to the event.
    all('a', text: 'Sign In')[0].click

    # Logout and log back in as admin.
    visit('/')
    common_login($admin_email, $admin_password)

    # Verify that event appears in list of events attended.
    all('a', text: 'Show')[0].click
    expect(page).to have_content('Event 1')

    # Show list of events that user has attended.
    visit('/users')
    all('a', text: 'Show')[0].click
    @curr_path = current_path.to_s
    expect(page).to have_content('User Information')

    # Visit user page directly.
    visit(@curr_path)
    expect(page).to have_content('Events Attended')

  end
end


# Promote a user to admin.
RSpec.describe 'Promote a user to admin.' do
  it 'Changes the user to an admin on the users page.' do
    
    # Create admin and user customers.
    create_admin
    create_user

    # Log in.
    visit('/')
    common_login($admin_email, $admin_password)
    visit('/users')

    # Expect to have both admins and users.
    expect(page).to have_content('user')
    expect(page).to have_content('admin')

    # Update the user to an admin.
    all('a', text: 'Update Role')[0].click
    expect(current_path).to include('edit')
    select('admin', from: 'customer_role')
    click_on('Submit')

    # Make sure that there are no more admin customers left.
    visit('/users')
    expect(page).to have_no_content('user')

  end
end

# Attempt to show a user that does not exist.
RSpec.describe 'Show information for a user that does not exist.' do
  it 'Redirects back to /users path.' do
  
    # Create admin and user customers.
    create_admin
    create_user

    # Log in as admin.
    visit('/')
    common_login($admin_email, $admin_password)
    visit('/users')

    # Attempt to show a user with an invalid ID.
    visit('/users/500')
    expect(page).to have_no_content('User Information')

  end
end

# Attempt to promote a user that does not exist.
RSpec.describe 'Promote a user that does not exist.' do
  it 'Redirects back to /users path.' do
    
    # Create admin and user customers.
    create_admin
    create_user

    # Log in as admin.
    visit('/')
    common_login($admin_email, $admin_password)
    visit('/users')

    # Attempt to edit a user with an invalid ID.
    visit('/users/500/edit')
    expect(page).to have_no_content('Update User Role')

  end
end

# Attempt to delete a user that does not exist.
RSpec.describe 'Delete a user that does not exist.' do
  it 'Redirects back to /users path.' do
    
    # Create admin and user customers.
    create_admin
    create_user

    # Log in as admin.
    visit('/')
    common_login($admin_email, $admin_password)
    visit('/users')

    # Attempt to edit a user with an invalid ID.
    visit('/users/500/delete')
    expect(page).to have_no_content('Delete User')

  end
end



# Attempt to delete a user that has already been deleted.
RSpec.describe 'Delete a user that has already been deleted.' do
  it 'Redirects back to /users path.' do

    # Create admin and user customers.
    create_admin
    create_user

    # Log in as admin.
    visit('/')
    common_login($admin_email, $admin_password)
    visit('/users')

    # Delete a user.
    all('a', text: 'Delete')[0].click
    click_on('Delete User')
    visit('/users')

    # Attempt to delete the user again.
    visit('/users/2/delete')
    expect(page).to have_no_content('Delete User')

  end
end

# Attempt to destroy a user that has already been deleted.
RSpec.describe 'Destroy a user that has already been deleted.' do
  it 'Redirects back to /users path.' do

    # Create admin and user customers.
    create_admin
    create_user

    @c = Customer.second

    # Log in as admin.
    visit('/')
    common_login($admin_email, $admin_password)
    visit('/users')

    # Attempt to delete user.
    all('a', text: 'Delete')[0].click

    @c.destroy
    click_on('Delete User')

  end
end

# Attempt to update a user that has already been deleted.
RSpec.describe 'Update a user that has already been deleted.' do
  it 'Redirects back to /users path.' do
    # Create admin and user customers.
    create_admin
    create_user

    @c = Customer.second

    # Log in as admin.
    visit('/')
    common_login($admin_email, $admin_password)
    visit('/users')

    # Attempt to update user.
    all('a', text: 'Update Role')[0].click

    @c.destroy
    click_on('Submit')    
    
  end
end

RSpec.describe 'Show a user that has already been deleted.' do
  it 'Redirects back to /users path.' do

    # Create admin and user customers.
    create_admin
    create_user

    # Log in as admin.
    visit('/')
    common_login($admin_email, $admin_password)
    visit('/users')

    # Delete a user.
    all('a', text: 'Delete')[0].click
    click_on('Delete User')
    visit('/users')

    # Attempt to show the user's information.
    visit('/users/2')
    expect(page).to have_no_content('User Information')

  end
end

# Delete a user.
RSpec.describe 'Delete a user.' do
  it 'Removes that user from the users page.' do

    # Create admin and user customers.
    create_admin
    create_user

    # Log in.
    visit('/')
    common_login($admin_email, $admin_password)
    visit('/users')

    # Expect to have both admins and users.
    expect(page).to have_content('user')
    expect(page).to have_content('admin')

    # Delete the user.
    all('a', text: 'Delete')[0].click
    expect(current_path).to include('/delete')
    click_on('Delete User')

    # Expect for the user to have been removed.
    visit('/users')
    expect(current_path).to eql('/users')
    expect(page).to have_no_content('Jane Doe')
    expect(page).to have_no_content('user')

  end
end

# Attempt to view the /users page as a non-admin.
RSpec.describe 'Attempt to view /users page as a non-admin.' do
  it 'Redirects user back to /events page.' do

    # Create admin and user customers.
    create_admin
    create_user

    # Log in as user.
    visit('/')
    common_login($user_email, $user_password)

    # Attempt to view the /users page.
    visit('/users')
    expect(page).to have_no_content('Current Members')

  end
end


