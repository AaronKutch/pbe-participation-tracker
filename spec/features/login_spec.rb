require 'rails_helper'
require_relative '../common'

admin_email = 'admin@test.com'
admin_password = 'p'

RSpec.describe 'Login to the application.' do

  it 'Takes the user to the login page.' do

    common_login("user", admin_email, admin_password)

  end
end

RSpec.describe 'Attempt login with empty fields.' do
  it 'Does not allow the user to continue until fields are completed.' do

    Customer.create(:first_name => 'John', :last_name => 'Smith', :email => admin_email, :password => admin_password)

    visit('/')
    click_on('Log In')
    expect(current_path).to eql('/access/login')
    click_on('Log In')
    expect(current_path).to eql('/access/attempt_login')
    fill_in('email', :with => admin_email)
    click_on('Log In')
    expect(current_path).to eql('/access/attempt_login')
    fill_in('email', :with => '')
    fill_in('password', :with => admin_password)
    click_on('Log In')
    expect(current_path).to eql('/access/attempt_login')
    fill_in('email', :with => admin_email)
    fill_in('password', :with => admin_password)
    click_on('Log In')
    expect(current_path).to eql('/events')

  end
end

