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
    when SpecialOfferType::THREE_FOR_TWO
      generate_x_for_y_discount(product, quantity, offer, unit_price, 3, 2)
    when SpecialOfferType::TWO_FOR_AMOUNT
      x = 2
      amount = offer.argument
      if quantity >= x
        quantity_as_int = quantity.to_i
        number_of_x = quantity_as_int / x
        total = amount * number_of_x + quantity_as_int % x * unit_price
        discount_amount = unit_price * quantity - total
        Discount.new(product, "#{x} for #{amount}", discount_amount)
      end
    when SpecialOfferType::FIVE_FOR_AMOUNT
      x = 5
      amount = offer.argument
      if quantity >= x
        quantity_as_int = quantity.to_i
        number_of_x = quantity_as_int / x
        total = amount * number_of_x + quantity_as_int % x * unit_price
        discount_amount = unit_price * quantity - total
        Discount.new(product, "#{x} for #{amount}", discount_amount)
      end
    when SpecialOfferType::TEN_PERCENT_DISCOUNT
      generate_percentage_discount(product, quantity, offer, unit_price)
    end
  end

  def generate_x_for_y_discount(product, quantity, _offer, unit_price, x, y)
    if quantity >= x
      quantity_as_int = quantity.to_i
      number_of_x = quantity_as_int / x
      total = (number_of_x * y * unit_price) + quantity_as_int % x * unit_price
      discount_amount = quantity * unit_price - total
      Discount.new(product, "#{x} for #{y}", discount_amount)
    end
  end

  def generate_percentage_discount(product, quantity, offer, unit_price)
    percentage = offer.argument
    discount_amount = quantity * unit_price * offer.argument / 100.0
    Discount.new(product, "#{percentage}% off", discount_amount)
  end
end
