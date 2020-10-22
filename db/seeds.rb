# frozen_string_literal: true

# NOTE this seeding is only for manual testing purposes for development.
# Can be reproduced with `rake db:reset`.
puts 'Running seeds.rb'
unless Rails.env.development? || Rails.env.test?
  raise 'Error: tried to run `seeds.rb` outside of development environment'
end

e0 = Event.new
# make sure that arbitrary strings cannot confuse exports or anything. It doesn't seem possible to
# run `e.save` when using special characters like \ or different parenthesis.
e0.title = "test event \"\' 0987654321qwertyuioplkjhgfdsazxcv🅱nm"
e0.description = 'this is a test event for development purposes'
e0.date = 'January 1970'
e0.end_time = 'December 2099'
e0.location = 'Texas A&M College Station'
e0.mandatory = true
raise 'Error: could not add test event' unless e0.save

e1 = Event.new
e1.title = 'event Ω'
e1.description = 'this is a test event for development purposes'
e1.date = '1 January 2020'
e1.end_time = '31 December 2020'
e1.location = 'Texas A&M College Station'
e1.mandatory = false
raise 'Error: could not add test event' unless e1.save

c0 = Customer.new
c0.first_name = 'test'
c0.last_name = 'admin'
c0.email = 'admin@tamu.edu'
c0.role = 'admin'
c0.password = 'p'
raise 'Error: could not add admin test account' unless c0.save

c0.events << e1

c1 = Customer.new
c1.first_name = 'test'
c1.last_name = 'user'
c1.email = 'user@tamu.edu'
c1.role = 'user'
c1.password = 'p'
raise 'Error: could not add user test account' unless c1.save

c1.events << e1

(65..90).each do |x|
  e = Event.new
  e.title = "event #{x.chr}"
  e.description = 'this is a test event for development purposes'
  today = Date.today + (x - 70)
  e.date = "#{today.day}-#{today.month}-#{today.year}"
  today += 1
  e.end_time = "#{today.day}-#{today.month}-#{today.year}"
  e.location = 'Texas A&M College Station'
  e.mandatory = true
  raise 'Error: could not add test event' unless e.save

  c = Customer.new
  c.first_name = "User-#{x}"
  c.last_name = "lastname-#{x.chr}.chr"
  c.email = "user-#{x}@tamu.edu"
  c.role = 'user'
  c.password = 'p'
  raise 'Error: could not add user test account' unless c.save

  # the account registers for one corresponding event
  c.events << e
  # all accounts register for event Omega
  c.events << e1
end
