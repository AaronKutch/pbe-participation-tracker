# frozen_string_literal: true

# NOTE this seeding is only for manual testing purposes for development.
# Can be reproduced with `rake db:reset`.
puts 'Running seeds.rb'
unless Rails.env.development? || Rails.env.test?
  raise 'Error: tried to run `seeds.rb` outside of development environment'
end

e = Event.new
e.title = 'test event'
e.description = 'this is a test event for development purposes'
e.date = 'January 2021'
e.end_time = 'February 2021'
e.location = 'Texas A&M College Station'
e.mandatory = false
raise 'Error: could not add test event' unless e.save

c0 = Customer.new
c0.first_name = 'test'
c0.last_name = 'admin'
c0.email = 'admin@tamu.edu'
c0.role = 'admin'
c0.password = 'p'
raise 'Error: could not add admin test account' unless c0.save

c0.events << e

c1 = Customer.new
c1.first_name = 'test'
c1.last_name = 'user'
c1.email = 'user@tamu.edu'
c1.role = 'user'
c1.password = 'p'
raise 'Error: could not add user test account' unless c1.save

c1.events << e
