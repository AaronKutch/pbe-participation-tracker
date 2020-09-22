# NOTE this seeding is only for manual testing purposes for development
puts "Seeding a database from `seeds.rb`, only do this on the development database."
c = Customer.new
c.first_name = 'f'
c.last_name = 'l'
c.email = 'admin@tamu.edu'
c.role = 'admin'
c.password = 'p'
if !c.save
    # best solved by `rake db:reset db:migrate db:seed`
    puts "Error: could not add admin test account"
end

c = Customer.new
c.first_name = 'f'
c.last_name = 'l'
c.email = 'guest@tamu.edu'
c.role = 'guest'
c.password = 'p'
if !c.save
    puts "Error: could not add guest test account"
end
