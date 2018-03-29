# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20180329165707) do

  create_table "bills", :force => true do |t|
    t.integer  "barcode",     :limit => 8,                                                 :null => false
    t.integer  "prod_count"
    t.decimal  "amount",                   :precision => 15, :scale => 2
    t.string   "bill_kind",                                                                :null => false
    t.integer  "client_id"
    t.text     "items",                                                                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "discount",                 :precision => 15, :scale => 2, :default => 0.0
    t.integer  "order_id"
    t.string   "client_kind", :limit => 1
  end

  add_index "bills", ["barcode"], :name => "index_bills_on_barcode"

  create_table "boxes", :force => true do |t|
    t.integer  "day"
    t.integer  "month"
    t.integer  "year"
    t.integer  "count",                                     :default => 0
    t.decimal  "total",      :precision => 15, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "categoria"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["categoria"], :name => "index_categories_on_categoria", :unique => true

  create_table "clients", :force => true do |t|
    t.string   "name",                                                        :null => false
    t.string   "last_name",                                                   :null => false
    t.string   "document",                                                    :null => false
    t.string   "address"
    t.string   "email"
    t.string   "location"
    t.integer  "phone"
    t.string   "cellphone"
    t.string   "client_kind",                                                 :null => false
    t.string   "bill_kind"
    t.decimal  "amount",      :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "spend",       :precision => 15, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uic"
    t.string   "uic_type"
  end

  add_index "clients", ["document"], :name => "index_clients_on_document", :unique => true
  add_index "clients", ["last_name"], :name => "index_clients_on_last_name"

  create_table "line_items", :force => true do |t|
    t.integer  "product_id"
    t.integer  "cart_id"
    t.integer  "order_id"
    t.decimal  "price",      :precision => 15, :scale => 2
    t.decimal  "quantity",   :precision => 15, :scale => 2, :default => 1.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "client_id"
    t.string   "bill_kind"
    t.boolean  "to_amount",                                 :default => false
    t.decimal  "price",      :precision => 15, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["client_id"], :name => "index_orders_on_client_id"

  create_table "payments", :force => true do |t|
    t.integer  "client_id",                                                  :null => false
    t.decimal  "deposit",    :precision => 15, :scale => 2
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.decimal  "debt_rest",  :precision => 10, :scale => 2, :default => 0.0
  end

  create_table "products", :force => true do |t|
    t.string   "barcode"
    t.string   "name",                                                         :null => false
    t.string   "mark"
    t.string   "fragance"
    t.decimal  "price",       :precision => 15, :scale => 2,                   :null => false
    t.decimal  "count",       :precision => 15, :scale => 2,                   :null => false
    t.string   "uni"
    t.decimal  "stock",       :precision => 15, :scale => 2, :default => 0.0
    t.decimal  "pricedist",   :precision => 15, :scale => 2
    t.decimal  "iva",         :precision => 15, :scale => 2, :default => 21.0
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "earn",        :precision => 15, :scale => 2, :default => 30.0
  end

  add_index "products", ["barcode"], :name => "index_products_on_barcode", :unique => true
  add_index "products", ["name"], :name => "index_products_on_name"

  create_table "shift_closures", :force => true do |t|
    t.datetime "start_at",                                                                  :null => false
    t.datetime "finish_at"
    t.decimal  "initial_amount",              :precision => 10, :scale => 0, :default => 0, :null => false
    t.decimal  "cashbox_amount",              :precision => 10, :scale => 0, :default => 0, :null => false
    t.text     "first_and_last_info_to_json"
    t.decimal  "payoffs",                     :precision => 10, :scale => 0, :default => 0, :null => false
    t.decimal  "system_amount",               :precision => 10, :scale => 0, :default => 0, :null => false
    t.decimal  "final_amount",                :precision => 10, :scale => 0, :default => 0, :null => false
    t.integer  "user_id",                                                                   :null => false
    t.text     "comments"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "username",                               :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "roles_mask",             :default => 0,  :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.integer  "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"
  add_index "versions", ["whodunnit"], :name => "index_versions_on_whodunnit"

end
