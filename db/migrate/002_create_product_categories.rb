class CreateProductCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :product_categories do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug
      t.integer :position

      t.timestamps
    end

    add_index :product_categories, [:merchant_id, :name], unique: true
    add_index :product_categories, [:merchant_id, :slug], unique: true
  end
end