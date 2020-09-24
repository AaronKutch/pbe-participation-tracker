# common function for logging in with a role, email, and password
def common_login(role, email, password)
  Customer.create(:first_name => 'John', :last_name => 'Smith', :role => role, :email => email, :password => password)

  visit('/')
  fill_in('Email', :with => email)
  fill_in('Password', :with => password)
  click_on('Log In')

  expect(current_path).to eql('/events')
end
