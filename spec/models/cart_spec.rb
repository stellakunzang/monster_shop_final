require 'rails_helper'

RSpec.describe Cart do
  describe 'Instance Methods' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 2 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @cart = Cart.new({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })
    end

    it '.contents' do
      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })
    end

    it '.add_item()' do
      @cart.add_item(@hippo.id.to_s)

      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2,
        @hippo.id.to_s => 1
        })
    end

    it '.count' do
      expect(@cart.count).to eq(3)
    end

    it '.items' do
      expect(@cart.items).to eq([@ogre, @giant])
    end

    it '.grand_total' do
      expect(@cart.grand_total).to eq(120)
    end

    it '.count_of()' do
      expect(@cart.count_of(@ogre.id)).to eq(1)
      expect(@cart.count_of(@giant.id)).to eq(2)
    end

    it '.subtotal_of()' do
      expect(@cart.subtotal_of(@ogre.id)).to eq(20)
      expect(@cart.subtotal_of(@giant.id)).to eq(100)
    end

    it '.limit_reached?()' do
      expect(@cart.limit_reached?(@ogre.id)).to eq(false)
      expect(@cart.limit_reached?(@giant.id)).to eq(true)
    end

    it '.less_item()' do
      @cart.less_item(@giant.id.to_s)

      expect(@cart.count_of(@giant.id)).to eq(1)
    end

    it '.cart_merchants' do
      @cart.add_item(@hippo.id.to_s)

      expect(@cart.cart_merchants).to eq([@megan.id, @brian.id])
    end

    it '.item_on_sale' do
      discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 100.0)
      discount.discount_items.create!(item_id: @giant.id)

      expect(@cart.item_on_sale(@giant, discount)).to eq(true)
      expect(@cart.item_on_sale(@ogre, discount)).to eq(false)
    end

    it '.valid_discounts' do
      expect(@cart.valid_discounts).to eq([])

      discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 50.0)
      discount.discount_items.create!(item_id: @giant.id)
      discount.discount_items.create!(item_id: @ogre.id)

      expect(@cart.valid_discounts).to eq([discount])
    end

    it '.validate_attributes' do
      discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 100.0)
      discount.discount_items.create!(item_id: @giant.id)
      discount.discount_items.create!(item_id: @ogre.id)
      expect(@cart.validate_attributes([discount])).to eq({discount.id => {quantity: 3, value: 120 }})
    end

    it '.discount_qualifications_met' do
      discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 100.0)
      discount.discount_items.create!(item_id: @ogre.id)

      expect(@cart.discount_qualifications_met([discount])).to eq([])

      discount.discount_items.create!(item_id: @giant.id)
      expect(@cart.discount_qualifications_met([discount])).to eq([discount])
    end

    it '.best_discount' do
      @cart.add_item(@hippo.id.to_s)
      @cart.add_item(@hippo.id.to_s)
      discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 100.0)
      discount2 = @brian.discounts.create!(percent_discount: 50.0, minimum_value: 50.0)
      discount2.discount_items.create!(item_id: @hippo.id)
      discount.discount_items.create!(item_id: @giant.id)
      discount.discount_items.create!(item_id: @ogre.id)

      expect(@cart.best_discount).to eq(discount2)
    end

    it '.determine_discount' do
      discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 100.0)
      discount.discount_items.create!(item_id: @giant.id)
      discount.discount_items.create!(item_id: @ogre.id)

      expect(@cart.determine_discount).to eq(discount)

      @cart.add_item(@hippo.id.to_s)
      @cart.add_item(@hippo.id.to_s)

      discount2 = @brian.discounts.create!(percent_discount: 50.0, minimum_value: 50.0)
      discount2.discount_items.create!(item_id: @hippo.id)

      expect(@cart.determine_discount).to eq(discount2)
    end

    it '.discount_applied' do
      expect(@cart.discount_applied).to eq(false)

      discount = @megan.discounts.create!(percent_discount: 25.0, minimum_quantity: 3)
      discount.discount_items.create!(item_id: @giant.id)
      discount.discount_items.create!(item_id: @ogre.id)

      expect(@cart.discount_applied).to eq(true)
    end

    it '.price_with_discount' do
      discount = @megan.discounts.create!(percent_discount: 25.0, minimum_quantity: 3)
      discount.discount_items.create!(item_id: @giant.id)
      discount.discount_items.create!(item_id: @ogre.id)

      expect(@cart.price_with_discount(@ogre.price)).to eq(15)
    end

    it 'subtotal_with_discount' do
      discount = @megan.discounts.create!(percent_discount: 25.0, minimum_quantity: 3)
      @cart.add_item(@ogre.id.to_s)
      discount.discount_items.create!(item_id: @giant.id)
      discount.discount_items.create!(item_id: @ogre.id)

      expect(@cart.subtotal_with_discount(@ogre.id)).to eq(30)
    end

  end
end
