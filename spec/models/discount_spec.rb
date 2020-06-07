require 'rails_helper'

RSpec.describe Discount do
  describe 'relationships' do
    it {should have_many :discount_items}
    it {should have_many(:items).through(:discount_items)}
    it {should belong_to :merchant}
  end

  describe 'validations' do
    it {should validate_presence_of :percent_discount}
  end

  describe 'instance methods' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @discount = @megan.discounts.create!(percent_discount: 10.0, minimum_value: 5.0, minimum_quantity: 5)
      @item_1 = @discount.discount_items.create!(item_id: @giant.id)
      @item_2 = @discount.discount_items.create!(item_id: @ogre.id)
    end

    it "#items_list" do
      expect(@discount.items_list).to eq("#{@ogre.name} and #{@giant.name}")
    end
    
  end
end
