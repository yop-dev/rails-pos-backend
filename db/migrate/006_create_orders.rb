class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :merchant, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :delivery_address, null: true, foreign_key: { to_table: :addresses }
      t.string :reference, null: false
      t.integer :source, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :voucher_code
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :shipping_fee_cents, null: false, default: 0
      t.integer :convenience_fee_cents, null: false, default: 0
      t.integer :discount_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.string :shipping_method_code
      t.string :shipping_method_label
      t.string :payment_method_code
      t.string :payment_method_label
      t.string :payment_link
      t.datetime :placed_at
      t.datetime :confirmed_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :orders, :reference, unique: true
    add_index :orders, [:merchant_id, :status]
    add_index :orders, [:merchant_id, :source]
  end
end