# common function for logging in with email and password
def common_login(email, password)
  visit('/')
  fill_in('Email', with: email)
  fill_in('Password', with: password)
  click_on('Log In')

  expect(current_path).to eql('/events')
end

# create an admin "John Smith" and login as him
def admin_create_and_login
  Customer.create(first_name: 'john', last_name: 'smith', role: 'admin', email: 'admin@test.com', password: 'p')
  common_login('admin@test.com', 'p')
end
