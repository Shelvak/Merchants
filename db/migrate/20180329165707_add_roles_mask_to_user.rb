class AddRolesMaskToUser < ActiveRecord::Migration
  def change
    add_column :users, :roles_mask, :integer, null: false, default: 0
  end
end
