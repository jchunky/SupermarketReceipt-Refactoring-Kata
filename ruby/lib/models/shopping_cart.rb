class ShoppingCart
  include SpecialOfferType

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
    @product_quantities.each do |product, quantity|
      next unless offers.key?(product)

      offer = offers[product]
      unit_price = catalog.unit_price(product)
      discount = generate_discount(product, quantity, offer, unit_price)
      receipt.add_discount(discount) if discount
    end
  end

  private

  def generate_discount(product, quantity, offer, unit_price)
    case offer.offer_type
    when THREE_FOR_TWO
      generate_x_for_y_discount(product, quantity, unit_price, 3, 2)
    when TWO_FOR_AMOUNT
      amount = offer.argument
      generate_x_for_amount_discount(product, quantity, unit_price, 2, amount)
    when FIVE_FOR_AMOUNT
      amount = offer.argument
      generate_x_for_amount_discount(product, quantity, unit_price, 5, amount)
    when TEN_PERCENT_DISCOUNT
      generate_percentage_discount(product, quantity, offer, unit_price)
    end
  end

  def generate_x_for_y_discount(product, quantity, unit_price, x, y)
    return if quantity < x

    quantity_as_int = quantity.to_i
    number_of_x = quantity_as_int / x
    total = (number_of_x * y * unit_price) + quantity_as_int % x * unit_price
    discount_amount = quantity * unit_price - total
    Discount.new(product, "#{x} for #{y}", discount_amount)
  end

  def generate_x_for_amount_discount(product, quantity, unit_price, x, amount)
    return if quantity < x

    quantity_as_int = quantity.to_i
    number_of_x = quantity_as_int / x
    total = amount * number_of_x + quantity_as_int % x * unit_price
    discount_amount = unit_price * quantity - total
    Discount.new(product, "#{x} for #{amount}", discount_amount)
  end

  def generate_percentage_discount(product, quantity, offer, unit_price)
    percentage = offer.argument
    discount_amount = quantity * unit_price * offer.argument / 100.0
    Discount.new(product, "#{percentage}% off", discount_amount)
  end
end
