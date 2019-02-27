class AddAndChangeColumnsToBills < ActiveRecord::Migration
  def change
    # rename_column :bills, :date, :prod_count
    add_column :bills, :prod_count, :integer
    add_column :bills, :discount, :decimal, precision: 15, scale: 2, default: 0
  end
end
