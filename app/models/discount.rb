class Discount < ApplicationRecord
  has_many :discount_items
  has_many :items, through: :discount_items
  belongs_to :merchant

  validates_presence_of :percent_discount
  validates_presence_of :minimum_value, presence: true, unless: :minimum_quantity
  validates_presence_of :minimum_quantity, presence: true, unless: :minimum_value

  def items_list
    items.pluck(:name).to_sentence 
  end
end
