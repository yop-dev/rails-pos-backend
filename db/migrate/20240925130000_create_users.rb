class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:users)
      create_table :users do |t|
        t.string :firstName, null: false
        t.string :lastName, null: false
        t.string :email, null: false
        t.string :password_digest, null: false
        t.string :role, null: false, default: 'staff'
        
        t.timestamps
      end
      
      add_index :users, :email, unique: true unless index_exists?(:users, :email)
    end
  end
end
