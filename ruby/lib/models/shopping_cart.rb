class ShoppingCart
  attr_reader :items, :product_quantities

  def initialize
    @items = []
    @product_quantities = {}
  end

  def add_item_quantity(product, quantity)
    @items << ProductQuantity.new(product, quantity)
    product_quantities[product] ||= 0
    product_quantities[product] += quantity
  end

  def handle_offers(receipt, offers, catalog)
    @product_quantities
      .select { |product, _| offers.key?(product) }
      .map { |product, quantity| calculate_discount(offers[product], catalog.unit_price(product), product, quantity) }
      .compact
      .each { |discount| receipt.add_discount(discount) }
  end

  def calculate_discount(offer, unit_price, p, quantity)
    case offer.offer_type
    when SpecialOfferType::PERCENT_DISCOUNT
      percent_discount(unit_price, p, quantity, offer.argument)
    when SpecialOfferType::THREE_FOR_TWO
      buy_2_get_1_free(unit_price, p, quantity)
    when SpecialOfferType::TWO_FOR_AMOUNT
      buy_x_quantity_for_fixed_price(unit_price, p, quantity, offer.argument, 2)
    when SpecialOfferType::FIVE_FOR_AMOUNT
      buy_x_quantity_for_fixed_price(unit_price, p, quantity, offer.argument, 5)
    else
      raise "Unexpected offer type: #{offer.offer_type}"
    end
  end

  def percent_discount(unit_price, p, quantity, discount_percentage)
    discount_amount = quantity * unit_price * discount_percentage / 100.0

    Discount.new(p, "#{discount_percentage}% off", discount_amount)
  end

  def buy_2_get_1_free(unit_price, p, quantity)
    discount_divisor = 3
    return nil if quantity < discount_divisor

    discount_price = unit_price * 2

    number_of_discounts = quantity.to_i / discount_divisor
    number_of_fullprice_items = quantity.to_i % discount_divisor

    total_price_for_discounted_items = discount_price * number_of_discounts
    total_price_for_nondiscounted_items = unit_price * number_of_fullprice_items

    total = total_price_for_discounted_items + total_price_for_nondiscounted_items

    discount_amount = unit_price * quantity - total

    Discount.new(p, "#{discount_divisor} for 2", discount_amount)
  end

  def buy_x_quantity_for_fixed_price(unit_price, p, quantity, discount_price, discount_divisor)
    return nil if quantity < discount_divisor

    number_of_discounts = quantity.to_i / discount_divisor
    number_of_fullprice_items = quantity.to_i % discount_divisor

    total_price_for_discounted_items = discount_price * number_of_discounts
    total_price_for_nondiscounted_items = unit_price * number_of_fullprice_items

    total = total_price_for_discounted_items + total_price_for_nondiscounted_items

    discount_amount = unit_price * quantity - total

    Discount.new(p, "#{discount_divisor} for #{discount_price}", discount_amount)
  end
end
