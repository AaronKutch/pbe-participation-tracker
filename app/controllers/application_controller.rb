# frozen_string_literal: true

# Shared application controller
class ApplicationController < ActionController::Base
  private

  # Restricts access to users that are logged in:
  # add 'before_action: confirm_logged_in' to the top of every login-restricted controller
  def confirm_logged_in
    return if session[:user_id]

    flash[:notice] = 'Please log in.'
    redirect_to(access_login_path)
  end

  def confirm_permissions
    return if Customer.where(id: session[:user_id]).first.role == 'admin'

    flash[:notice] = "You don't have permission to do that"
    redirect_to(events_path)
  end
end
