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
    @items << ProductQuantity.new(product, quantity)
    product_quantities[product] ||= 0
    product_quantities[product] += quantity
  end

  def handle_offers(receipt, offers, catalog)
    @product_quantities.each do |p, quantity|
      next unless offers.key?(p)

      offer = offers[p]
      unit_price = catalog.unit_price(p)
      discount = build_discount(offer, unit_price, p, quantity)
      receipt.add_discount(discount) if discount
    end
  end

  def build_discount(offer, unit_price, p, quantity)
    case offer.offer_type
    when SpecialOfferType::THREE_FOR_TWO
      x = 3
      y = 2
      discount = build_x_for_y_discount(unit_price, p, quantity, x, y)
    when SpecialOfferType::TWO_FOR_AMOUNT
      x = 2
      y = offer.argument
      discount = build_x_for_y_discount(unit_price, p, quantity, x, y)
    when SpecialOfferType::FIVE_FOR_AMOUNT
      x = 5
      y = offer.argument
      discount = build_x_for_y_discount(unit_price, p, quantity, x, y)
    when SpecialOfferType::TEN_PERCENT_DISCOUNT
      discount = Discount.new(
        p,
        offer.argument.to_s + '% off',
        quantity * unit_price * offer.argument / 100.0
      )
    end
  end

  def build_x_for_y_discount(unit_price, p, quantity, x, y)
    quantity_as_int = quantity.to_i

    if quantity_as_int >= x
      number_of_x = quantity_as_int / x
      total = (y * number_of_x + quantity_as_int % x) * unit_price
      discount_amount = quantity * unit_price - total
      Discount.new(p, x.to_s + ' for ' + y.to_s, discount_amount)
    end
  end
end
