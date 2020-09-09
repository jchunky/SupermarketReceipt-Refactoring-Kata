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
      .map { |product, quantity| calculate_discount(offers[product], catalog, product, quantity) }
      .compact
      .each { |discount| receipt.add_discount(discount) }
  end

  def calculate_discount(offer, catalog, p, quantity)
    case offer.offer_type
    when SpecialOfferType::PERCENT_DISCOUNT
      percent_discount(offer, catalog, p, quantity)
    when SpecialOfferType::THREE_FOR_TWO
      buy_2_get_1_free(offer, catalog, p, quantity)
    when SpecialOfferType::TWO_FOR_AMOUNT
      buy_x_quantity_for_fixed_price(offer, catalog, p, quantity, 2)
    when SpecialOfferType::FIVE_FOR_AMOUNT
      buy_x_quantity_for_fixed_price(offer, catalog, p, quantity, 5)
    else
      raise "Unexpected offer type: #{offer.offer_type}"
    end
  end

  def percent_discount(offer, catalog, p, quantity)
    unit_price = catalog.unit_price(p)

    discount_percentage = offer.argument

    discount_amount = quantity * unit_price * offer.argument / 100.0

    Discount.new(p, "#{discount_percentage}% off", discount_amount)
  end

  def buy_2_get_1_free(_offer, catalog, p, quantity)
    discount_divisor = 3
    return nil if quantity < discount_divisor

    unit_price = catalog.unit_price(p)
    discount_price = unit_price * 2

    number_of_discounts = quantity.to_i / discount_divisor
    number_of_fullprice_items = quantity.to_i % discount_divisor

    total_price_for_discounted_items = discount_price * number_of_discounts
    total_price_for_nondiscounted_items = unit_price * number_of_fullprice_items

    total = total_price_for_discounted_items + total_price_for_nondiscounted_items

    discount_amount = unit_price * quantity - total

    Discount.new(p, "#{discount_divisor} for 2", discount_amount)
  end

  def buy_x_quantity_for_fixed_price(offer, catalog, p, quantity, discount_divisor)
    return nil if quantity < discount_divisor

    unit_price = catalog.unit_price(p)
    discount_price = offer.argument

    number_of_discounts = quantity.to_i / discount_divisor
    number_of_fullprice_items = quantity.to_i % discount_divisor

    total_price_for_discounted_items = discount_price * number_of_discounts
    total_price_for_nondiscounted_items = unit_price * number_of_fullprice_items

    total = total_price_for_discounted_items + total_price_for_nondiscounted_items

    discount_amount = unit_price * quantity - total

    Discount.new(p, "#{discount_divisor} for #{discount_price}", discount_amount)
  end
end
