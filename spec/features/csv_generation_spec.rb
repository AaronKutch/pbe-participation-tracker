# frozen_string_literal: true

require 'rails_helper'
require_relative '../common'

# Attempt to generate a QR code for an event.
RSpec.describe 'Attempt to generate a CSV of attendances' do
  it 'Returns the /users/export_attendance_csv page.' do
    admin_create_and_login

    # Attempt to generate a QR code for event.
    visit(users_path)
    click_on('Export Attendance CSV')
    expect(current_path).to eq(users_export_attendance_csv_path)
    expect(page.status_code).to be(200)
  end
end
