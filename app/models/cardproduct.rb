require 'active_record'

class CardProduct < ActiveRecord::Base
	belongs_to :store, optional: true
	has_many :cards
end
