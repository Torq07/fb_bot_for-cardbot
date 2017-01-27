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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 1) do

  create_table "agents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "aid"
    t.string  "first_name"
    t.string  "last_name"
  end

  create_table "card_products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "type_name"
    t.bigint "store_id"
    t.index ["store_id"], name: "fk_rails_e0da833334", using: :btree
  end

  create_table "card_transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "status"
    t.string   "trans_type"
    t.float    "amount",     limit: 24
    t.bigint   "store_id"
    t.integer  "agent_id"
    t.integer  "card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["agent_id"], name: "index_card_transactions_on_agent_id", using: :btree
    t.index ["card_id"], name: "index_card_transactions_on_card_id", using: :btree
    t.index ["store_id"], name: "fk_rails_7090c4df60", using: :btree
  end

  create_table "cards", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "status"
    t.float   "balance",         limit: 24, default: 0.0
    t.date    "expiring_date"
    t.integer "card_product_id"
    t.bigint  "customer_id"
    t.bigint  "store_id"
    t.index ["card_product_id"], name: "index_cards_on_card_product_id", using: :btree
    t.index ["customer_id"], name: "fk_rails_778182f614", using: :btree
    t.index ["store_id"], name: "fk_rails_9335e2ff23", using: :btree
  end

  create_table "customers", id: :bigint, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.integer "activation_code"
    t.bigint  "fb_id"
  end

  create_table "stores", id: :bigint, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "store_name"
  end

  add_foreign_key "card_products", "stores"
  add_foreign_key "card_transactions", "agents"
  add_foreign_key "card_transactions", "cards"
  add_foreign_key "card_transactions", "stores"
  add_foreign_key "cards", "card_products"
  add_foreign_key "cards", "customers"
  add_foreign_key "cards", "stores"
end
