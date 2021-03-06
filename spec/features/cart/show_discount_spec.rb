require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Cart Show Page with Discount' do
  describe 'As a Visitor' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
    end

    describe 'I can see discounts in my cart' do
      it "discount is not applied if I don't meet requirements" do
        discount = @megan.discounts.create!(percent_discount: 25.0, minimum_quantity: 5)
        discount.discount_items.create!(item_id: @giant.id)
        discount.discount_items.create!(item_id: @ogre.id)

        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'

        visit '/cart'

        expect(page).to have_content("Total: #{number_to_currency(@ogre.price + @giant.price )}")

        within "#item-#{@ogre.id}" do
          expect(page).to have_link(@ogre.name)
          expect(page).to_not have_content("Discount:")
          expect(page).to_not have_content("Price (with Discount):")
          expect(page).to have_content("Quantity: 1")
          expect(page).to_not have_content("Subtotal (with Discount):")
          expect(page).to have_content("Sold by: #{@megan.name}")
          expect(page).to have_css("img[src*='#{@ogre.image}']")
          expect(page).to have_link(@megan.name)
        end

        within "#item-#{@giant.id}" do
          expect(page).to have_link(@giant.name)
          expect(page).to_not have_content("Discount:")
          expect(page).to_not have_content("Price (with Discount):")
          expect(page).to have_content("Quantity: 1")
          expect(page).to_not have_content("Subtotal (with Discount):")
          expect(page).to have_content("Sold by: #{@megan.name}")
          expect(page).to have_css("img[src*='#{@giant.image}']")
          expect(page).to have_link(@megan.name)
        end
      end

      it "if I meet the minimum value requirements for a merchant, discount is applied" do
        discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 100.0)
        discount.discount_items.create!(item_id: @giant.id)
        discount.discount_items.create!(item_id: @ogre.id)

        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'

        visit '/cart'

        total = ((@ogre.price * 1) + (@giant.price * 2))
        percent_decimal = (discount.percent_discount * 0.01)

        expect(page).to have_content("Total (with Discount): #{number_to_currency(total - (total * percent_decimal ))}")

        within "#item-#{@ogre.id}" do
          expect(page).to have_link(@ogre.name)
          expect(page).to have_content("Discount: #{discount.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency(@ogre.price - (@ogre.price * percent_decimal))}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency(@ogre.price - (@ogre.price * percent_decimal))}")
          expect(page).to have_content("Sold by: #{@megan.name}")
          expect(page).to have_css("img[src*='#{@ogre.image}']")
          expect(page).to have_link(@megan.name)
        end

        within "#item-#{@giant.id}" do
          expect(page).to have_link(@giant.name)
          expect(page).to have_content("Discount: #{discount.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency((@giant.price) -((@giant.price) * percent_decimal))}")
          expect(page).to have_content("Quantity: 2")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency((@giant.price * 2) - ((@giant.price * 2) * percent_decimal))}")
          expect(page).to have_content("Sold by: #{@megan.name}")
          expect(page).to have_css("img[src*='#{@giant.image}']")
          expect(page).to have_link(@megan.name)
        end
      end

      it "if I meet the minimum quantity requirements for a merchant, discount is applied" do
        discount = @megan.discounts.create!(percent_discount: 25.0, minimum_quantity: 3)
        discount.discount_items.create!(item_id: @giant.id)
        discount.discount_items.create!(item_id: @ogre.id)

        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'

        visit '/cart'

        total = ((@ogre.price * 1) + (@giant.price * 2))
        percent_decimal = (discount.percent_discount * 0.01)

        expect(page).to have_content("Total (with Discount): #{number_to_currency(total - (total * percent_decimal ))}")

        within "#item-#{@ogre.id}" do
          expect(page).to have_content("Discount: #{discount.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency(@ogre.price - (@ogre.price * percent_decimal))}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency(@ogre.price - (@ogre.price * percent_decimal))}")
        end

        within "#item-#{@giant.id}" do
          expect(page).to have_content("Discount: #{discount.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency((@giant.price) -((@giant.price) * percent_decimal))}")
          expect(page).to have_content("Quantity: 2")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency((@giant.price * 2) - ((@giant.price * 2) * percent_decimal))}")
        end
      end

      it "discount is only applied to a single merchant's items" do
        discount = @megan.discounts.create!(percent_discount: 50.0, minimum_value: 50.0)
        discount.discount_items.create!(item_id: @giant.id)
        discount.discount_items.create!(item_id: @ogre.id)

        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        total = (@ogre.price + @giant.price + @hippo.price)
        percent_decimal = (discount.percent_discount * 0.01)

        expect(page).to have_content("Total (with Discount): #{number_to_currency(total - ((@ogre.price + @giant.price) * percent_decimal))}")

        within "#item-#{@hippo.id}" do
          expect(page).to have_content("Price: #{number_to_currency(@hippo.price)}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal: #{number_to_currency(@hippo.price)}")
        end
      end

      it "discount can be limited to a specific item from a merchant" do
        discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 100.0)
        discount.discount_items.create!(item_id: @giant.id)

        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'

        visit '/cart'

        total = ((@ogre.price * 1) + (@giant.price * 2))
        percent_decimal = (discount.percent_discount * 0.01)

        expect(page).to have_content("Total (with Discount): #{number_to_currency(total - ((@giant.price * 2) * percent_decimal ))}")

        within "#item-#{@ogre.id}" do
          expect(page).to_not have_content("Discount:")
          expect(page).to_not have_content("Price (with Discount):")
          expect(page).to have_content("Quantity: 1")
          expect(page).to_not have_content("Subtotal (with Discount):")
        end

        within "#item-#{@giant.id}" do
          expect(page).to have_content("Discount: #{discount.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency((@giant.price) -((@giant.price) * percent_decimal))}")
          expect(page).to have_content("Quantity: 2")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency((@giant.price * 2) - ((@giant.price * 2) * percent_decimal))}")
        end
      end

      it "discount is applied as soon as minimum requirements are met" do
        discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 100.0)
        discount.discount_items.create!(item_id: @giant.id)

        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'

        visit '/cart'

        expect(page).to have_content("Total: #{(number_to_currency(@ogre.price + @giant.price))}")

        within "#item-#{@giant.id}" do
          expect(page).to_not have_content("Discount:")
          expect(page).to_not have_content("Price (with Discount):")
          expect(page).to have_content("Quantity: 1")
          expect(page).to_not have_content("Subtotal (with Discount):")
        end

        visit item_path(@giant)
        click_button 'Add to Cart'

        visit '/cart'

        total = ((@ogre.price * 1) + (@giant.price * 2))
        percent_decimal = (discount.percent_discount * 0.01)

        expect(page).to have_content("Total (with Discount): #{number_to_currency(total - ((@giant.price * 2) * percent_decimal ))}")

        within "#item-#{@giant.id}" do
          expect(page).to have_content("Discount: #{discount.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency((@giant.price) -((@giant.price) * percent_decimal))}")
          expect(page).to have_content("Quantity: 2")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency((@giant.price * 2) - ((@giant.price * 2) * percent_decimal))}")
        end
      end

      it "if 2 discounts are included, the greater of the 2 is applied" do
        discount = @megan.discounts.create!(percent_discount: 25.0, minimum_quantity: 3)
        discount2 = @megan.discounts.create!(percent_discount: 50.0, minimum_quantity: 5)
        discount.discount_items.create!(item_id: @giant.id)
        discount.discount_items.create!(item_id: @ogre.id)
        discount2.discount_items.create!(item_id: @giant.id)
        discount2.discount_items.create!(item_id: @ogre.id)

        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@ogre)
        click_button 'Add to Cart'

        visit '/cart'

        total = ((@ogre.price * 3) + (@giant.price * 2))
        percent_decimal = (discount2.percent_discount * 0.01)

        expect(page).to have_content("Total (with Discount): #{number_to_currency(total - (total * percent_decimal))}")

        within "#item-#{@ogre.id}" do
          expect(page).to have_content("Discount: #{discount2.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency(@ogre.price - (@ogre.price * percent_decimal))}")
          expect(page).to have_content("Quantity: 3")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency((@ogre.price * 3) - ((@ogre.price * 3) * percent_decimal))}")
        end

        within "#item-#{@giant.id}" do
          expect(page).to have_content("Discount: #{discount2.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency((@giant.price) -((@giant.price) * percent_decimal))}")
          expect(page).to have_content("Quantity: 2")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency((@giant.price * 2) - ((@giant.price * 2) * percent_decimal))}")
        end
      end

      it "discount is only applied to a single merchant's items" do
        discount = @megan.discounts.create!(percent_discount: 50.0, minimum_value: 50.0)
        discount.discount_items.create!(item_id: @giant.id)
        discount.discount_items.create!(item_id: @ogre.id)

        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        total = (@ogre.price + @giant.price + @hippo.price)
        percent_decimal = (discount.percent_discount * 0.01)

        expect(page).to have_content("Total (with Discount): #{number_to_currency(total - ((@ogre.price + @giant.price) * percent_decimal))}")

        within "#item-#{@hippo.id}" do
          expect(page).to have_content("Price: #{number_to_currency(@hippo.price)}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal: #{number_to_currency(@hippo.price)}")
        end
      end

      it "discount can be limited to a specific item from a merchant" do
        discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 100.0)
        discount.discount_items.create!(item_id: @giant.id)

        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'

        visit '/cart'

        total = ((@ogre.price * 1) + (@giant.price * 2))
        percent_decimal = (discount.percent_discount * 0.01)

        expect(page).to have_content("Total (with Discount): #{number_to_currency(total - ((@giant.price * 2) * percent_decimal ))}")

        within "#item-#{@ogre.id}" do
          expect(page).to_not have_content("Discount:")
          expect(page).to_not have_content("Price (with Discount):")
          expect(page).to have_content("Quantity: 1")
          expect(page).to_not have_content("Subtotal (with Discount):")
        end

        within "#item-#{@giant.id}" do
          expect(page).to have_content("Discount: #{discount.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency((@giant.price) -((@giant.price) * percent_decimal))}")
          expect(page).to have_content("Quantity: 2")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency((@giant.price * 2) - ((@giant.price * 2) * percent_decimal))}")
        end
      end

      it "discount is applied as soon as minimum requirements are met" do
        discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 100.0)
        discount.discount_items.create!(item_id: @giant.id)

        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'

        visit '/cart'

        expect(page).to have_content("Total: #{(number_to_currency(@ogre.price + @giant.price))}")

        within "#item-#{@giant.id}" do
          expect(page).to_not have_content("Discount:")
          expect(page).to_not have_content("Price (with Discount):")
          expect(page).to have_content("Quantity: 1")
          expect(page).to_not have_content("Subtotal (with Discount):")
        end

        visit item_path(@giant)
        click_button 'Add to Cart'

        visit '/cart'

        total = ((@ogre.price * 1) + (@giant.price * 2))
        percent_decimal = (discount.percent_discount * 0.01)

        expect(page).to have_content("Total (with Discount): #{number_to_currency(total - ((@giant.price * 2) * percent_decimal ))}")

        within "#item-#{@giant.id}" do
          expect(page).to have_content("Discount: #{discount.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency((@giant.price) -((@giant.price) * percent_decimal))}")
          expect(page).to have_content("Quantity: 2")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency((@giant.price * 2) - ((@giant.price * 2) * percent_decimal))}")
        end
      end

      it "discount can include both minimum value and minimum requirement" do
        discount = @megan.discounts.create!(percent_discount: 25.0, minimum_value: 100.0, minimum_quantity: 3)
        discount.discount_items.create!(item_id: @giant.id)
        discount.discount_items.create!(item_id: @ogre.id)

        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'
        visit item_path(@giant)
        click_button 'Add to Cart'

        visit '/cart'

        total = ((@ogre.price * 1) + (@giant.price * 2))
        percent_decimal = (discount.percent_discount * 0.01)

        expect(page).to have_content("Total (with Discount): #{number_to_currency(total - (total * percent_decimal))}")

        within "#item-#{@ogre.id}" do
          expect(page).to have_content("Discount: #{discount.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency(@ogre.price - (@ogre.price * percent_decimal))}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency(@ogre.price - (@ogre.price * percent_decimal))}")
        end

        within "#item-#{@giant.id}" do
          expect(page).to have_content("Discount: #{discount.percent_discount.round}%")
          expect(page).to have_content("Price (with Discount): #{number_to_currency((@giant.price) -((@giant.price) * percent_decimal))}")
          expect(page).to have_content("Quantity: 2")
          expect(page).to have_content("Subtotal (with Discount): #{number_to_currency((@giant.price * 2) - ((@giant.price * 2) * percent_decimal))}")
        end
      end
    end
  end
end
