class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :email, null: false
      t.string :phone
      t.string :first_name, null: false
      t.string :last_name, null: false

      t.timestamps
    end

    add_index :customers, [:merchant_id, :email], unique: true
    add_index :customers, [:merchant_id, :phone]
  end
end