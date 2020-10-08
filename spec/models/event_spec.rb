# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'event record' do
    context 'when created with no arguments' do
      it 'is not valid' do
        expect(Event.new.valid?).to eq(false)
      end
    end

    context 'when created with only a title' do
      it 'is not valid' do
        expect(Event.new(title: 'Informational').valid?).to eq(false)
      end
    end

    context 'when created with title and date' do
      it 'is valid' do
        expect(Event.new(title: 'Informational', date: DateTime.new(2020, 9, 20),
                         end_time: DateTime.new(2020, 11, 20), location: 'zoom').valid?).to eq(true)
      end
    end
  end
end
