class CreateMerchants < ActiveRecord::Migration[7.1]
  def change
    create_table :merchants do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.text :address
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :merchants, :email, unique: true
  end
end