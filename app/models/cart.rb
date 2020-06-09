class Cart
  attr_reader :contents

  def initialize(contents)
    @contents = contents || {}
    @contents.default = 0
  end

  def add_item(item_id)
    @contents[item_id] += 1
  end

  def less_item(item_id)
    @contents[item_id] -= 1
  end

  def count
    @contents.values.sum
  end

  def items
    @contents.map do |item_id, _|
      Item.find(item_id)
    end
  end

  def grand_total
    grand_total = 0.0
    @contents.each do |item_id, quantity|
      grand_total += Item.find(item_id).price * quantity
    end
    grand_total
  end

  def count_of(item_id)
    @contents[item_id.to_s]
  end

  def subtotal_of(item_id)
    @contents[item_id.to_s] * Item.find(item_id).price
  end

  def limit_reached?(item_id)
    count_of(item_id) == Item.find(item_id).inventory
  end

  def cart_merchants
    items.map do |item|
      item.merchant_id
    end.uniq
  end

  def valid_discounts
    possible_discounts = cart_merchants.map do |merchant_id|
      Merchant.find(merchant_id).discounts
    end.flatten
    discount_qualifications_met(possible_discounts)
  end

  def item_on_sale(item, discount)
    !DiscountItem.where('item_id = ? AND discount_id = ?', item.id, discount.id).empty? && item.merchant_id == discount.merchant_id
  end

  def validate_attributes(possible_discounts)
    totals = Hash.new { |hash, key| hash[key] = {quantity: 0, value: 0} }
    possible_discounts.each do |discount|
      items.each do |item|
        if item_on_sale(item, discount)
          totals[discount.id][:quantity] += count_of(item.id)
          totals[discount.id][:value] += subtotal_of(item.id)
        end
      end
    end
    totals
  end

  def discount_qualifications_met(possible_discounts)
    discounts = []
    validate_attributes(possible_discounts).find_all do |discount_id, totals|
      discount = Discount.find_by(id: discount_id)
      if discount.minimum_value == nil && totals[:quantity] >= discount.minimum_quantity
        discounts << discount
      elsif discount.minimum_quantity == nil && discount.minimum_value != nil && totals[:value] >= discount.minimum_value
        discounts << discount
      elsif discount.minimum_quantity != nil && discount.minimum_value != nil && totals[:value] >= discount.minimum_value && totals[:quantity] >= discount.minimum_quantity
        discounts << discount
      end
    end
    discounts
  end

  def determine_discount
    if valid_discounts.length == 1
      valid_discounts.first
    else
      best_discount
    end
  end

  def grand_total_with_discount
    total = 0.0
    discount = determine_discount
    items.each do |item|
      if item_on_sale(item, discount)
        total += subtotal_with_discount(item.id)
      else
        total += subtotal_of(item.id)
      end
    end
    total
  end

  def best_discount
    discount_totals = Hash.new { |hash, key| hash[key] = 0 }
    valid_discounts.each do |discount|
      items.each do |item|
        if item_on_sale(item, discount)
          discount_totals[discount.id] += (subtotal_of(item.id) - ((subtotal_of(item.id)) * (discount.percent_discount * 0.01)))
        else
          discount_totals[discount.id] += subtotal_of(item.id)
        end
      end
    end
    best = discount_totals.min_by{|discount_id, grandtotal| grandtotal}
    Discount.find_by(id: best[0])
  end

  def discount_applied
    !valid_discounts.empty?
  end

  def price_with_discount(item_price)
    item_price - (item_price * (determine_discount.percent_discount * 0.01))
  end

  def subtotal_with_discount(item_id)
    subtotal_of(item_id) - (subtotal_of(item_id) * (determine_discount.percent_discount * 0.01))
  end

end
