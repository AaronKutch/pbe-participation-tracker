# frozen_string_literal: true

class AccessController < ApplicationController
  before_action :confirm_logged_in, except: %i[login attempt_login logout]

  def menu
    # displays text and links
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
    redirect_to(events_path)
  end
end
