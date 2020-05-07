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
    quantity_as_int = quantity.to_i

    case offer.offer_type
    when SpecialOfferType::THREE_FOR_TWO
      x = 3
      y = 2
      x_for_y_discount(quantity, unit_price, x: 3, y: 2)
      if quantity >= x
        number_of_x = quantity_as_int / x
        total = (number_of_x * y * unit_price) + quantity_as_int % x * unit_price
        discount_amount = quantity * unit_price - total
        Discount.new(p, "#{x} for #{y}", discount_amount)
      end
    when SpecialOfferType::TEN_PERCENT_DISCOUNT
      percent = offer.argument
      discount = quantity * unit_price * percent / 100.0
      Discount.new(p, "#{percent}% off", discount)
    when SpecialOfferType::TWO_FOR_AMOUNT
      x = 2
      amount = offer.argument
      if quantity >= x
        number_of_x = quantity_as_int / x
        total = amount * number_of_x + quantity_as_int % x * unit_price
        discount = unit_price * quantity - total
        Discount.new(p, "#{x} for #{amount}", discount)
      end
    when SpecialOfferType::FIVE_FOR_AMOUNT
      x = 5
      amount = offer.argument
      if quantity >= x
        number_of_x = quantity_as_int / x
        total = amount * number_of_x + quantity_as_int % x * unit_price
        discount = unit_price * quantity - total
        Discount.new(p, "#{x} for #{amount}", discount)
      end
    else
      raise "Unexpected SpecialOfferType: #{offer.offer_type}"
    end
  end

  def x_for_y_discount(quantity, unit_price, x:, y:)
    quantity_as_int = quantity.to_i
    if quantity >= x
      number_of_x = quantity_as_int / x
      total = (number_of_x * y * unit_price) + quantity_as_int % x * unit_price
      discount_amount = quantity * unit_price - total
      Discount.new(p, "#{x} for #{y}", discount_amount)
    end
  end
end
