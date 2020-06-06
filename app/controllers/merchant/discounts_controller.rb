class Merchant::DiscountsController < Merchant::BaseController
  def new
    merchant = Merchant.find_by(id: current_user[:merchant_id])
    @items = merchant.items
  end

  def create
    params[:merchant_id] = current_user.merchant_id
    discount = Discount.create(discount_params)
    if discount.save
      items = params[:applicable_items].reject! {|item| item.empty?}
      if items.empty?
        Merchant.find(:merchant_id).items.each do |item|
          discount.discount_items.create ({ discount_id: discount.id, item_id: item.id })
        end 
      else
        items.each do |item_id|
          discount.discount_items.create ({ discount_id: discount.id, item_id: item_id })
        end
      end
    else
      flash[:notice] = "Percent discount is required as well as either minimum quantity or minimum value!"
      render :new
    end
  end

  private

  def discount_params
    params.permit(:merchant_id, :percent_discount, :minimum_quantity, :minimum_value)
  end
end
