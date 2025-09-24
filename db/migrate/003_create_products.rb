class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.references :merchant, null: false, foreign_key: true
      t.references :product_category, null: true, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :product_type, null: false, default: 0
      t.integer :price_cents, null: false
      t.string :currency, limit: 3, null: false, default: "PHP"
      t.string :photo_public_id
      t.string :photo_url
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :products, [:merchant_id, :active]
    add_index :products, [:merchant_id, :product_type]
  end
end