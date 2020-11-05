# frozen_string_literal: true

# Controller for help related pages
class HelpController < ApplicationController
  before_action :confirm_logged_in
  before_action :confirm_permissions

  def admin; end
end
