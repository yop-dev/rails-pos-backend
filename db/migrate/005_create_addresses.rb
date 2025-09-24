class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :street, null: false
      t.string :unit_floor_building
      t.string :barangay, null: false
      t.string :city, null: false
      t.string :province, null: false
      t.string :postal_code
      t.string :landmark
      t.text :remarks

      t.timestamps
    end

    # Index already created by t.references
  end
end