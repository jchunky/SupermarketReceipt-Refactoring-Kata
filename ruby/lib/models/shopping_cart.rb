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
    product_quantities.each do |product, quantity|
      offer = offers[product]
      unit_price = catalog.unit_price(product)
      description, discount_amount = get_discount(offer, quantity, unit_price)
      next unless discount_amount

      discount = Discount.new(product, description, discount_amount)
      receipt.add_discount(discount)
    end
  end

  private

  def get_discount(offer, quantity, unit_price)
    case offer&.offer_type
    when SpecialOfferType::TEN_PERCENT_DISCOUNT
      percent = offer.argument
      discount_amount = quantity * unit_price * percent / 100.0
      ["#{percent}% off", discount_amount]
    when SpecialOfferType::THREE_FOR_TWO
      quantity_as_int = quantity.to_i
      x = 3
      y = 2
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = (number_of_x * y * unit_price) + quantity_as_int % x * unit_price
      discount_amount = quantity * unit_price - total
      ["#{x} for #{y}", discount_amount]
    when SpecialOfferType::TWO_FOR_AMOUNT
      quantity_as_int = quantity.to_i
      x = 2
      amount = offer.argument
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = amount * (quantity_as_int / x) + quantity_as_int % x * unit_price
      discount_amount = unit_price * quantity - total
      ["#{x} for #{amount}", discount_amount]
    when SpecialOfferType::FIVE_FOR_AMOUNT
      quantity_as_int = quantity.to_i
      x = 5
      amount = offer.argument
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = amount * number_of_x + quantity_as_int % x * unit_price
      discount_amount = unit_price * quantity - total
      ["#{x} for #{amount}", discount_amount]
    end
  end
end
