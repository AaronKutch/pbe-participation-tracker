require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'constructor' do
    context 'when created with no arguments' do
      it 'is not valid' do
        expect(Customer.new.valid?).to eq(false)
      end
    end

    context 'when created with only a name' do
      it 'is not valid' do
        expect(Customer.new(first_name: 'John', last_name: 'Doe').valid?).to eq(false)
      end
    end

    context 'when created with name, email, and password' do
      it 'is valid' do
        expect(Customer.new(first_name: 'John', last_name: 'Doe', email: 'johndoe@mail.com', password: 'password').valid?).to eq(true)
      end
    end

    context 'when created' do
      it 'role is "user" by default' do
        expect(Customer.new.role).to eq('user')
      end
    end
  end
end

# security tests: user authentication and webpage protection (customer_spec.rb)
describe 'User authentication' do
  context 'When given invalid credentials' do
    it 'Reprompts the user.' do
      visit('/access/login')
      fill_in 'Email', with: 'example@something.com'
      fill_in 'Password', with: 'wrongpassword'
      click_button 'Log In'
      expect(current_path).to eql('/access/attempt_login')
      expect(page).to have_content 'Invalid email/password combination.'
    end
  end

  context 'When viewing events without signing in' do
    it 'Does not allow adding events.' do
      visit('/events')
      expect(page).not_to have_content 'Add new event'
    end

    it 'Does not allow editing events.' do
      visit('/events')
      expect(page).not_to have_content 'Edit'
    end

    it 'Does not allow deleting events.' do
      visit('/events')
      expect(page).not_to have_content 'Delete'
    end
  end

  context 'When trying to access protected pages without signing in' do
    it 'Redirects and reprompts the user.' do
      visit('/events/new')
      expect(current_path).to eql('/access/login')
      expect(page).to have_content 'Please log in.'
    end
  end
end
