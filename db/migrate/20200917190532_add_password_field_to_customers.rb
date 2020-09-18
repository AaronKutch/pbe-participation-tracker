class AddPasswordFieldToCustomers < ActiveRecord::Migration[6.0]
  def change
    remove_column "customers", "password"
    add_column "customers", "password_digest", :string, null: false
  end
end
