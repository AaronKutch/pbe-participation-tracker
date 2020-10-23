# frozen_string_literal: true

require 'rails_helper'
require_relative '../common'

# Attempt to generate a QR code for an event.
RSpec.describe 'Attempt to generate a CSV of attendances' do
  it 'Returns the /users/export_attendance_csv page.' do
    admin_create_and_login

    Event.create(
      title: 'TEST EVENT',
      description: 'This is an example event.',
      date: '2020-01-01 00:00:00',
      location: 'TEST LOCATION',
      mandatory: true,
      end_time: '2021-02-01 00:00:00'
    )

    Customer.first.events << Event.first

    # Attempt to generate a CSV file.
    visit(users_path)
    click_on('Export Attendance CSV')
    expect(current_path).to eq(users_export_attendance_csv_path)
    expect(page.status_code).to be(200)
  end
end
