# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# require 'active_record'
require "#{Rails.root}/app/models/cardproduct.rb"
# CardProduct.delete_all
# Store.delete_all
# Card.delete_all
Customer.delete_all

customer = Customer.create!([
  { 
    id: 380661189887, 
    first_name: 'Denis',
    last_name: 'Presnov',
    activation_code: 932
  }
  ])

card_products = CardProduct.create([
  {
    type_name: 'voucher'
  },
  {
    type_name: 'cash'
  },
  {
    type_name: 'loyalty'
  },
  {
    type_name: 'coupon'
  },
  {
    type_name: 'flyer'
  },
])

Store.delete_all

stores = Store.create!([
  {id:1, store_name:'X-mas store'},
  {id:2, store_name:'Walmart'},
])

cards = Card.create!([
  {
   status:'deactivated',
   balance:100, 
   expiring_date:20170519,
   card_product_id:3,
   customer_id:nil,
   store_id:1
  },
  {
   status:'deactivated',
   balance:150, 
   expiring_date:20170311,
   card_product_id:2,
   customer_id:nil,
   store_id:2
  },
  {
   status:'activated',
   balance:50, 
   expiring_date:20170308,
   card_product_id:5,
   customer_id:nil,
   store_id:2
  }
])
  
