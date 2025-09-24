# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 7) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "street", null: false
    t.string "unit_floor_building"
    t.string "barangay", null: false
    t.string "city", null: false
    t.string "province", null: false
    t.string "postal_code"
    t.string "landmark"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_addresses_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id", "email"], name: "index_customers_on_merchant_id_and_email", unique: true
    t.index ["merchant_id", "phone"], name: "index_customers_on_merchant_id_and_phone"
    t.index ["merchant_id"], name: "index_customers_on_merchant_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.text "address"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_merchants_on_email", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.string "product_name_snapshot", null: false
    t.integer "unit_price_cents", null: false
    t.integer "quantity", null: false
    t.integer "total_price_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.bigint "customer_id", null: false
    t.bigint "delivery_address_id"
    t.string "reference", null: false
    t.integer "source", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "voucher_code"
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "shipping_fee_cents", default: 0, null: false
    t.integer "convenience_fee_cents", default: 0, null: false
    t.integer "discount_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.string "shipping_method_code"
    t.string "shipping_method_label"
    t.string "payment_method_code"
    t.string "payment_method_label"
    t.string "payment_link"
    t.datetime "placed_at"
    t.datetime "confirmed_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["delivery_address_id"], name: "index_orders_on_delivery_address_id"
    t.index ["merchant_id", "source"], name: "index_orders_on_merchant_id_and_source"
    t.index ["merchant_id", "status"], name: "index_orders_on_merchant_id_and_status"
    t.index ["merchant_id"], name: "index_orders_on_merchant_id"
    t.index ["reference"], name: "index_orders_on_reference", unique: true
  end

  create_table "product_categories", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.string "name", null: false
    t.string "slug"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id", "name"], name: "index_product_categories_on_merchant_id_and_name", unique: true
    t.index ["merchant_id", "slug"], name: "index_product_categories_on_merchant_id_and_slug", unique: true
    t.index ["merchant_id"], name: "index_product_categories_on_merchant_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "merchant_id", null: false
    t.bigint "product_category_id"
    t.string "name", null: false
    t.text "description"
    t.integer "product_type", default: 0, null: false
    t.integer "price_cents", null: false
    t.string "currency", limit: 3, default: "PHP", null: false
    t.string "photo_public_id"
    t.string "photo_url"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id", "active"], name: "index_products_on_merchant_id_and_active"
    t.index ["merchant_id", "product_type"], name: "index_products_on_merchant_id_and_product_type"
    t.index ["merchant_id"], name: "index_products_on_merchant_id"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
  end

  add_foreign_key "addresses", "customers"
  add_foreign_key "customers", "merchants"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "addresses", column: "delivery_address_id"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "merchants"
  add_foreign_key "product_categories", "merchants"
  add_foreign_key "products", "merchants"
  add_foreign_key "products", "product_categories"
end
