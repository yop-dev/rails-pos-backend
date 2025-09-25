class RemoveVoucherFieldsFromOrders < ActiveRecord::Migration[7.1]
  def change
    remove_column :orders, :voucher_code, :string
    remove_column :orders, :discount_cents, :integer
  end
end