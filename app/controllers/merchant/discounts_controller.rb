class Merchant::DiscountsController < Merchant::BaseController

  def index
    @discounts = Discount.all
  end

  def new
    merchant = Merchant.find_by(id: current_user[:merchant_id])
    @items = merchant.items
  end

  def create
    params[:merchant_id] = current_user.merchant_id
    discount = Discount.create(discount_params)
    if discount.save
      item_ids = params[:applicable_items].values.flatten.reject! {|id| id.empty? }
      if item_ids.empty?
        Merchant.find(current_user[:merchant_id]).items.each do |item|
          discount.discount_items.create ({ discount_id: discount.id, item_id: item.id })
        end
      else
        item_ids.each do |item_id|
          discount.discount_items.create ({ discount_id: discount.id, item_id: item_id })
        end
      end
      redirect_to "/merchant/discounts"
    else
      flash[:notice] = "Percent discount is required as well as either minimum quantity or minimum value!"
      redirect_to "/merchant/discounts/new"
    end
  end

  def edit
    @discount = Discount.find(params[:id])
  end

  def update
    @discount = Discount.find(params[:id])
    @discount.update(discount_params)
    redirect_to("/merchant/discounts")
  end

  def destroy
    discount = Discount.find(params[:id])
    discount.destroy
    redirect_to '/merchant/discounts'
  end

  private

  def discount_params
    params.permit(:merchant_id, :percent_discount, :minimum_quantity, :minimum_value)
  end
end
