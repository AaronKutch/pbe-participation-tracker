require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'constructor' do
    context 'when created with no arguments' do
      it 'is not valid' do
        expect(Customer.new.valid?).to eq(false)
      end
    end

    context 'when created with only a name' do
      it 'is not valid' do
        expect(Customer.new(:first_name => "John", :last_name => "Doe").valid?).to eq(false)
      end
    end

    context 'when created with name, email, and password' do
      it 'is valid' do
        expect(Customer.new(:first_name => "John", :last_name => "Doe", :email => "johndoe@mail.com", :password => "password").valid?).to eq(true)
      end
    end

    context 'when created' do
      it 'role is "user" by default' do
        expect(Customer.new.role).to eq("user")
      end
    end
  end
end
