# NOTE this seeding is only for manual testing purposes for development.
# Can be reproduced with `rake db:reset db:migrate db:seed`.
if Rails.env.development?
  e = Event.new
  e.title = 'test event'
  e.description = 'this is a test event for development purposes'
  e.date = 'January 2021'
  e.location = 'Texas A&M College Station'
  e.mandatory = false
  unless e.save
    puts "Error: could not add test event"
  end

  c0 = Customer.new
  c0.first_name = 'test'
  c0.last_name = 'admin'
  c0.email = 'admin@tamu.edu'
  c0.role = 'admin'
  c0.password = 'p'
  if c0.save
    c0.events << e
  else
    puts "Error: could not add admin test account"
  end

  c1 = Customer.new
  c1.first_name = 'test'
  c1.last_name = 'user'
  c1.email = 'user@tamu.edu'
  c1.role = 'user'
  c1.password = 'p'
  if c1.save
    c1.events << e
  else
    puts "Error: could not add user test account"
  end
else
  puts "Error: tried to run `seeds.rb` outside of development environment"
end
