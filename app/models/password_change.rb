# frozen_string_literal: true

# Form object for passing old and new password information.
class PasswordChange
  include ActiveModel::Model

  attr_accessor :old_password, :new_password
end
