class CreateShiftClosures < ActiveRecord::Migration
  def change
    create_table :shift_closures do |t|
      t.datetime :start_at, null: false
      t.datetime :finish_at
      t.decimal :initial_amount, null: false, default: 0.0, precision: 15, scale: 2
      t.decimal :cashbox_amount, null: false, default: 0.0, precision: 15, scale: 2
      t.text :first_and_last_info_to_json, default: ''

      t.decimal :payoffs, null: false, default: 0.0, precision: 15, scale: 2

      t.decimal :system_amount, null: false, default: 0.0, precision: 15, scale: 2
      t.decimal :final_amount, null: false, default: 0.0, precision: 15, scale: 2

      t.integer :user_id, null: false, index: true
      t.text :comments

      t.timestamps null: false
    end
  end
end
