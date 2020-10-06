# frozen_string_literal: true

require 'rails_helper'
require_relative '../common'

RSpec.describe 'New account' do
  context 'when on the create account page' do
    it 'shows the correct content' do
      visit access_new_account_path
      expect(page).to have_content('First name')
      expect(page).to have_content('Last name')
      expect(page).to have_content('Email')
      expect(page).to have_content('Password')
    end
  end

  context 'when given valid information' do
    it 'creates an account' do
      visit access_new_account_path

      # Create first account
      fill_in('customer_first_name', with: 'Rake')
      fill_in('customer_last_name', with: 'User')
      fill_in('customer_email', with: 'rake@user.com')
      fill_in('customer_password', with: 'password')
      click_on('Create Account')

      expect(current_path).to eq(access_login_path)
    end
  end

  context 'when not given all fields' do
    it 'prevents account creation' do
      visit access_new_account_path
      click_on('Create Account')
      expect(page).to have_content('First name')
      expect(page).to have_content('Last name')
      expect(page).to have_content('Email')
      expect(page).to have_content('Password')
    end
  end

  context 'when given a duplicate email' do
    it 'prevents account creation' do
      visit access_new_account_path

      # Create first account
      fill_in('customer_first_name', with: 'Rake')
      fill_in('customer_last_name', with: 'User')
      fill_in('customer_email', with: 'rake@user.com')
      fill_in('customer_password', with: 'password')
      click_on('Create Account')

      visit access_new_account_path
      # Create account with duplicate email
      fill_in('customer_first_name', with: 'Next')
      fill_in('customer_last_name', with: 'User')
      fill_in('customer_email', with: 'rake@user.com')
      fill_in('customer_password', with: 'password')
      click_on('Create Account')
      expect(page).to have_content('Email has already been taken')

    end
  end
end