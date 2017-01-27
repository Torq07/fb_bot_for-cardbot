require 'active_record'
# require './models/cardtransaction'

class Card < ActiveRecord::Base
	has_many :card_transactions
	belongs_to :customer, optional: true
	belongs_to :store, optional: true
	belongs_to :card_product, optional: true
end
