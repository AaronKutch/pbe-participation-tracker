# frozen_string_literal: true

# Shared application controller
class ApplicationController < ActionController::Base
  private

  # Restricts access to users that are logged in:
  # add 'before_action: confirm_logged_in' to the top of every login-restricted controller
  def confirm_logged_in
    unless session[:user_id]
      flash[:notice] = 'Please log in.'
      redirect_to(access_login_path)
    end
  end

  def confirm_permissions
    unless Customer.find(id: session[:user_id]).role == 'admin'
      flash[:notice] = 'You are not authorized to view this page.'
      redirect_to(events_path)
    end
  end
end
