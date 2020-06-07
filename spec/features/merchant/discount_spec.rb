require 'rails_helper'

RSpec.describe 'New bulk discount' do
  describe 'As a Merchant employee' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
      @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @nessie = @merchant_1.items.create!(name: 'Nessie', description: "I'm a Loch Monster!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @merchant_1.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: false, inventory: 3 )
      @hippo = @merchant_2.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m_user)
    end

    it "I can click a link to a new bulk discount form" do
      visit "/merchant"

      click_link "Create New Bulk Discount"

      expect(current_path).to eq("/merchant/discounts/new")
    end

    it "I can create a discount for a merchant" do
      visit "/merchant/discounts/new"

      fill_in :percent_discount, with: 10
      fill_in :minimum_quantity, with: 5
      fill_in :minimum_value, with: 40

      find("input[id='applicable_items_id_#{@ogre.id}']").click

      click_button 'Create Discount'

      expect(current_path).to eq("/merchant/discounts")

      expect(page).to have_content("Discount: 10%")
      expect(page).to have_content("Minimum Quantity: 5")
      expect(page).to have_content("Minimum Value: $40.00")
      expect(page).to have_content("Applicable Items: #{@ogre.name}")
    end

    it "I can create a discount for a merchant including multiple items" do
      visit "/merchant/discounts/new"

      find("input[id='applicable_items_id_#{@ogre.id}']").click
      find("input[id='applicable_items_id_#{@nessie.id}']").click

      fill_in :percent_discount, with: 10
      fill_in :minimum_quantity, with: 5
      fill_in :minimum_value, with: 40
      click_button 'Create Discount'

      expect(current_path).to eq("/merchant/discounts")

      expect(page).to have_content("Discount: 10%")
      expect(page).to have_content("Minimum Quantity: 5")
      expect(page).to have_content("Minimum Value: $40.00")
      expect(page).to have_content("Applicable Items: #{@ogre.name} and #{@nessie.name}")
    end

    it "I can create a discount for a merchant and leave items blank, which defaults to all items" do
      visit "/merchant/discounts/new"

      fill_in :percent_discount, with: 10
      fill_in :minimum_quantity, with: 5
      fill_in :minimum_value, with: 40
      click_button 'Create Discount'

      expect(page).to have_content("Discount: 10%")
      expect(page).to have_content("Minimum Quantity: 5")
      expect(page).to have_content("Minimum Value: $40.00")
      expect(page).to have_content("Applicable Items: #{@ogre.name}, #{@nessie.name}, and #{@giant.name}")
    end

    it "I can create a discount by specifying percent and quantity, without value" do
      visit "/merchant/discounts/new"

      fill_in :percent_discount, with: 10
      fill_in :minimum_quantity, with: 5
      click_button 'Create Discount'

      expect(page).to have_content("Discount: 10%")
      expect(page).to have_content("Minimum Quantity: 5")
      expect(page).to_not have_content("Minimum Value")
    end

    it "I can create a discount by specifying percent and value, without quantity" do
      visit "/merchant/discounts/new"

      fill_in :percent_discount, with: 10
      fill_in :minimum_value, with: 40
      click_button 'Create Discount'

      expect(page).to have_content("Discount: 10%")
      expect(page).to have_content("Minimum Value: $40.00")
      expect(page).to_not have_content("Minimum Quantity")
    end

    it "I cannot create a discount without specifying percent and either quantity or value" do
      visit "/merchant/discounts/new"

      fill_in :percent_discount, with: 10
      click_button 'Create Discount'

      expect(page).to have_content("Percent discount is required as well as either minimum quantity or minimum value!")

      fill_in :percent_discount, with: 10
      fill_in :minimum_value, with: 40
      click_button 'Create Discount'

      expect(page).to have_content("Discount: 10%")
      expect(page).to have_content("Minimum Value: $40.00")
    end

    it "I can have multiple discounts active at once" do
       discount_1 = @merchant_1.discounts.create!(percent_discount: 10.0, minimum_value: 5.0, minimum_quantity: 5)
       discount_2 = @merchant_1.discounts.create!(percent_discount: 50.0, minimum_value: 100.0)
       discount_1.discount_items.create!(item_id: @giant.id)
       discount_1.discount_items.create!(item_id: @ogre.id)
       discount_2.discount_items.create!(item_id: @giant.id)
       discount_2.discount_items.create!(item_id: @ogre.id)
       discount_2.discount_items.create!(item_id: @nessie.id)

      visit "/merchant/discounts"

      within "#discount-#{discount_1.id}" do
        expect(page).to have_content("Discount: 10%")
        expect(page).to have_content("Minimum Value: $5.00")
        expect(page).to have_content("Minimum Quantity: 5")
        expect(page).to have_content("Applicable Items: #{@ogre.name} and #{@giant.name}")
      end

      within "#discount-#{discount_2.id}" do
        expect(page).to have_content("Discount: 50%")
        expect(page).to have_content("Minimum Value: $100.00")
        expect(page).to have_content("Applicable Items: #{@ogre.name}, #{@nessie.name}, and #{@giant.name}")
      end

    end
  end
end
