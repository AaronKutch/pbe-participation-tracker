# frozen_string_literal: true

require 'rails_helper'
require_relative '../common'

user_email = 'user@test.com'
password = 'p'

RSpec.describe 'Login to the application.' do
  it 'Takes the user to the login page.' do
    Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: user_email, password: password)
    common_login(user_email, password)
  end
end

RSpec.describe 'Attempt login with empty fields.' do
  it 'Does not allow the user to continue until fields are completed.' do
    Customer.create(first_name: 'Jane', last_name: 'Doe', role: 'user', email: user_email, password: password)
    common_login(user_email, password)

    visit('/')
    click_on('Log In')
    expect(current_path).to eql('/access/attempt_login')
    click_on('Log In')
    expect(current_path).to eql('/access/attempt_login')
    fill_in('email', with: user_email)
    click_on('Log In')
    expect(current_path).to eql('/access/attempt_login')
    fill_in('email', with: '')
    fill_in('password', with: password)
    click_on('Log In')
    expect(current_path).to eql('/access/attempt_login')
    fill_in('email', with: user_email)
    fill_in('password', with: password)
    click_on('Log In')
    expect(current_path).to eql('/events')
  end
end
