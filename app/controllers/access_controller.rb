# frozen_string_literal: true

# Controller for user accounts and authentication
class AccessController < ApplicationController
  before_action :confirm_logged_in, except: %i[login attempt_login logout new_account create_account]

  def new_account
    # displays new account form
    @new_customer = Customer.new
  end

  def create_account
    # creates account in database
    @info = params[:customer]
    @new_customer = Customer.new
    @new_customer.first_name = @info[:first_name]
    @new_customer.last_name = @info[:last_name]
    @new_customer.email = @info[:email]
    @new_customer.password = @info[:password]

    if @new_customer.save
      redirect_to(access_login_path, notice: 'Account created successfully!')
    else
      render('new_account')
    end
  end

  def login
    # login form
  end

  def attempt_login
    if params[:email].present? && params[:password].present?
      found_user = Customer.where(email: params[:email]).first
      authorized_user = found_user.authenticate(params[:password]) if found_user
    end

    if authorized_user
      session[:user_id] = authorized_user.id
      redirect_to(events_path)
    else
      flash.now[:notice] = 'Invalid email/password combination.'
      render('login')
    end
  end

  def logout
    session[:user_id] = nil
    render('login')
  end
end
