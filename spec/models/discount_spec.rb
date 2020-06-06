require 'rails_helper'

RSpec.describe Discount do
  describe 'relationships' do
    it {should have_many :discount_items}
    it {should have_many(:items).through(:discount_items)}
    it {should belong_to :merchant}
  end
end 
