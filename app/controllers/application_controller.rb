# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  # Restricts access to users that are logged in:
  # add 'before_action: confirm_logged_in' to the top of every login-restricted controller
  def confirm_logged_in
    if session[:user_id]
      nil
    else
      flash[:notice] = 'Please log in.'
      redirect_to(access_login_path)
    end
  end
end
