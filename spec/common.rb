# frozen_string_literal: true

# default_start_time = [Date.today.year, Date.today.month, Date.today.day, '12 AM', '00']
# default_end_time = [Date.today.year, Date.today.month, Date.today.day, '11 PM', '59']

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

# creates event (via create page) that is ready to be signed into.
def create_available_event(title="title", location="location")
  click_on('Add new event')
  fill_in('event_title', with: title)
  fill_in('event_location', with: location)
  select 'January', from: 'event_date_2i'
  select Date.today.day, from: 'event_date_3i'
  select '12 AM', from: 'event_date_4i'
  select '00', from: 'event_date_5i'
  select Date.today.year + 1, from: 'event_end_time_1i'
  select '11 PM', from: 'event_end_time_4i'
  select '59', from: 'event_end_time_5i'
  click_on('Submit')

  expect(page).to have_content(title)
  expect(current_path).to eql('/events')
end

# creates event (via create page) based on specific parameters
def create_custom_event(title, location, start_time, end_time, mandatory = false, description="")
  click_on('Add new event')
  expect(current_path).to eql('/events/new')
  fill_in('event_title', with: title)
  fill_in('event_location', with: location)
  fill_in('event_description', with: description)

  # fill in date (start time)
  select start_time[0], from: 'event_date_1i'
  select start_time[1], from: 'event_date_2i'
  select start_time[2], from: 'event_date_3i'
  select start_time[3], from: 'event_date_4i'
  select start_time[4], from: 'event_date_5i' 

  # fill in end_time
  select end_time[0], from: 'event_end_time_1i'
  select end_time[1], from: 'event_end_time_2i'
  select end_time[2], from: 'event_end_time_3i'
  select end_time[3], from: 'event_end_time_4i'
  select end_time[4], from: 'event_end_time_5i'

  # mark as not mandatory
  if mandatory == false
    uncheck('event_mandatory')
  end

  # create event and check for correct routing
  click_on('Submit')
  expect(current_path).to eql('/events')
end
