class Merchant::DiscountsController < Merchant::BaseController
  def new
    merchant = Merchant.find_by(id: current_user[:merchant_id])
    @items = merchant.items 
  end

  def create
  end

  private


end
