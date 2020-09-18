require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'contructor' do
    context 'when created with no arguments' do
      it 'throws an error' do
        expect{Event.create}.to raise_error(/NotNullViolation/)
      end
    end

    context 'when created with only title' do
      it 'throws an error' do
        expect{Event.create(:title => "Informational")}.to raise_error(/NotNullViolation/)
      end
    end

    context 'when created with minimum required arguments' do
      it 'creates expected record' do
        expect{Event.create(:title => "Informational", :date => DateTime.new(2020, 9, 20))}.to_not raise_error
      end
    end
  end
end
