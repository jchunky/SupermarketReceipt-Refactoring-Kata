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
    product_quantities.each_key do |p|
      next unless offers.key?(p)

      discount = discount(offers, catalog, p)

      receipt.add_discount(discount) if discount
    end
  end

  def discount(offers, catalog, p)
    quantity = product_quantities[p]
    offer = offers[p]
    unit_price = catalog.unit_price(p)

    case offer.offer_type
    when SpecialOfferType::THREE_FOR_TWO
      x_for_y_discount(p, quantity, unit_price, x: 3, y: 2)
    when SpecialOfferType::TEN_PERCENT_DISCOUNT
      percent = offer.argument
      percent_discount(p, quantity, unit_price, percent: percent)
    when SpecialOfferType::TWO_FOR_AMOUNT
      amount = offer.argument
      x_for_amount_discount(p, quantity, unit_price, x: 2, amount: amount)
    when SpecialOfferType::FIVE_FOR_AMOUNT
      amount = offer.argument
      x_for_amount_discount(p, quantity, unit_price, x: 5, amount: amount)
    else
      raise "Unexpected SpecialOfferType: #{offer.offer_type}"
    end
  end

  def x_for_y_discount(product, quantity, unit_price, x:, y:)
    if quantity >= x
      total = quantity / x * y * unit_price + quantity % x * unit_price
      discount_amount = quantity * unit_price - total
      Discount.new(product, "#{x} for #{y}", discount_amount)
    end
  end

  def percent_discount(product, quantity, unit_price, percent:)
    discount_amount = quantity * unit_price * percent / 100.0
    Discount.new(product, "#{percent}% off", discount_amount)
  end

  def x_for_amount_discount(product, quantity, unit_price, x:, amount:)
    if quantity >= x
      total = quantity / x * amount + quantity % x * unit_price
      discount_amount = quantity * unit_price - total
      Discount.new(product, "#{x} for #{amount}", discount_amount)
    end
  end
end
