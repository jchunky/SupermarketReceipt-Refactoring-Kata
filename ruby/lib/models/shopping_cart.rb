class ShoppingCart
  attr_reader :items, :product_quantities
  def initialize
    @items = []
    @product_quantities = {}
  end

  def add_item(product)
    add_item_quantity(product, 1.0)
  end

  def add_item_quantity(product, quantity)
    items << ProductQuantity.new(product, quantity)
    product_quantities[product] ||= 0
    product_quantities[product] += quantity
  end

  def handle_offers(receipt, offers, catalog)
    product_quantities.each do |p, quantity|
      next unless offers.key?(p)

      offer = offers[p]
      unit_price = catalog.unit_price(p)
      discount = find_discount(p, unit_price, quantity, offer)
      receipt.add_discount(discount) if discount
    end
  end

  def find_discount(p, unit_price, quantity, offer)
    case offer.offer_type
    when SpecialOfferType::THREE_FOR_TWO
      x = 3
      y = 2
      discount = x_for_y_discount(p, unit_price, quantity, x, y)
    when SpecialOfferType::TWO_FOR_AMOUNT
      x = 2
      amount = offer.argument
      discount = x_for_amount_discount(p, unit_price, quantity, x, amount)
    when SpecialOfferType::FIVE_FOR_AMOUNT
      x = 5
      amount = offer.argument
      discount = x_for_amount_discount(p, unit_price, quantity, x, amount)
    when SpecialOfferType::TEN_PERCENT_DISCOUNT
      percent = offer.argument
      discount = percent_discount(p, unit_price, quantity, percent)
    end
  end

  def x_for_y_discount(product, unit_price, quantity, x, y)
    return if quantity < x

    quantity_as_int = quantity.to_i
    number_of_x = quantity_as_int / x
    total = (number_of_x * y * unit_price) + quantity_as_int % x * unit_price
    discount_amount = quantity * unit_price - total
    Discount.new(product, "#{x} for #{y}", discount_amount)
  end

  def x_for_amount_discount(product, unit_price, quantity, x, amount)
    return if quantity < x

    quantity_as_int = quantity.to_i
    number_of_x = quantity_as_int / x
    total = amount * number_of_x + quantity_as_int % x * unit_price
    discount_amount = quantity * unit_price - total
    Discount.new(product, "#{x} for #{amount}", discount_amount)
  end

  def percent_discount(product, unit_price, quantity, percent)
    discount_amount = quantity * unit_price * percent / 100.0
    Discount.new(product, "#{percent}% off", discount_amount)
  end
end
