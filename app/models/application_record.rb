# frozen_string_literal: true

# Root record class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
