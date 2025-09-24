class AddCustomerSearchIndexes < ActiveRecord::Migration[7.1]
  def change
    # Add trigram extension for better ILIKE performance
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')
    
    # Add GIN indexes for full-text search on customer fields
    # These indexes will significantly speed up ILIKE queries
    add_index :customers, :email, 
              using: :gin, 
              opclass: :gin_trgm_ops,
              name: 'index_customers_on_email_trgm'
              
    add_index :customers, :phone, 
              using: :gin, 
              opclass: :gin_trgm_ops,
              name: 'index_customers_on_phone_trgm',
              where: "phone IS NOT NULL"
              
    add_index :customers, :first_name, 
              using: :gin, 
              opclass: :gin_trgm_ops,
              name: 'index_customers_on_first_name_trgm'
              
    add_index :customers, :last_name, 
              using: :gin, 
              opclass: :gin_trgm_ops,
              name: 'index_customers_on_last_name_trgm'
    
    # Add composite index for combined name search
    add_index :customers, [:merchant_id, :first_name, :last_name],
              name: 'index_customers_on_merchant_and_names'
              
    # Add computed column for full name search if needed
    # This can be added later if we need to search full names frequently
  end

  def down
    remove_index :customers, name: 'index_customers_on_email_trgm'
    remove_index :customers, name: 'index_customers_on_phone_trgm'
    remove_index :customers, name: 'index_customers_on_first_name_trgm'
    remove_index :customers, name: 'index_customers_on_last_name_trgm'
    remove_index :customers, name: 'index_customers_on_merchant_and_names'
  end
end