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
    when X_FOR_Y
      generate_x_for_y_discount(product, quantity, offer, unit_price)
    when X_FOR_AMOUNT
      generate_x_for_amount_discount(product, quantity, offer, unit_price)
    when PERCENT_DISCOUNT
      generate_percentage_discount(product, quantity, offer, unit_price)
    end
  end

  def generate_x_for_y_discount(product, quantity, offer, unit_price)
    x = offer.argument[:x]
    y = offer.argument[:y]
    return if quantity < x

    quantity_as_int = quantity.to_i
    number_of_x = quantity_as_int / x
    total = (number_of_x * y * unit_price) + quantity_as_int % x * unit_price
    discount_amount = quantity * unit_price - total
    Discount.new(product, "#{x} for #{y}", discount_amount)
  end

  def generate_x_for_amount_discount(product, quantity, offer, unit_price)
    x = offer.argument[:x]
    amount = offer.argument[:amount]
    return if quantity < x

    quantity_as_int = quantity.to_i
    number_of_x = quantity_as_int / x
    total = amount * number_of_x + quantity_as_int % x * unit_price
    discount_amount = unit_price * quantity - total
    Discount.new(product, "#{x} for #{amount}", discount_amount)
  end

  def generate_percentage_discount(product, quantity, offer, unit_price)
    percent = offer.argument[:percent]
    discount_amount = quantity * unit_price * percent / 100
    Discount.new(product, "#{percent}% off", discount_amount)
  end
end
