class Event < ApplicationRecord
    has_and_belongs_to_many :customers

    validates_presence_of :title, :date
    validates_length_of :title, :maximum => 50
    validates_length_of :location, :maximum => 128
end
