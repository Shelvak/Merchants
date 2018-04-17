class ChangeShiftClosures < ActiveRecord::Migration
  def up
    add_column :shift_closures, :payoffs_detail, :string, default: nil
  end

  def down
    remove_column :shift_closures, :payoffs_detail
  end
end
