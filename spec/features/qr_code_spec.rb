# frozen_string_literal: true

require 'rails_helper'
require_relative '../common'

# Attempt to generate a QR code for an event.
RSpec.describe 'Attempt to generate a QR code for an event.' do
  it 'Returns the /generate_qr_code page.' do
    admin_create_and_login

    # Create an event.
    Event.create(
      title: 'TEST EVENT',
      description: 'This is an example event.',
      date: '2020-01-01 00:00:00',
      location: 'TEST LOCATION',
      mandatory: true,
      end_time: '2021-02-01 00:00:00'
    )

    # Attempt to generate a QR code for event.
    visit('/events')
    all('a', text: 'Details')[0].click
    click_on('Generate QR Code')
    expect(current_path).to include('/events/generate_qr_code')
    expect(page).to have_content('Event QR Code')
  end
end

# Attempt to generate a QR code for an event that has already been deleted.
RSpec.describe 'Attempt to generate a QR code for an event that has already been deleted.' do
  it 'Redirects user back to /events path.' do
    admin_create_and_login

    # Create an event.
    create_test_event

    # Attempt to generate a QR code for event.
    visit('/events')
    all('a', text: 'Details')[0].click
    @event_id = Event.first.id
    expect(current_path).to eql("/events/#{@event_id}")
    Event.first.destroy
    click_on('Generate QR Code')
    expect(current_path).to eql('/events')
  end
end
