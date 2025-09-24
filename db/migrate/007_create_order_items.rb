class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :product_name_snapshot, null: false
      t.integer :unit_price_cents, null: false
      t.integer :quantity, null: false
      t.integer :total_price_cents, null: false

      t.timestamps
    end

    # Indexes already created by t.references
  end
end