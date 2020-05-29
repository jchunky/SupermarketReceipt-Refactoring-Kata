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
    product_quantities[product] =
      if @product_quantities.key?(product)
        product_quantities[product] + quantity
      else
        quantity
      end
  end

  def handle_offers(receipt, offers, catalog)
    @product_quantities.each_key do |p|
      next unless offers.key?(p)

      discount = get_discount(offers, catalog, p)

      receipt.add_discount(discount) if discount
    end
  end

  private

  def get_discount(offers, catalog, p)
    discount = nil
    offer = offers[p]

    case offer.offer_type
    when SpecialOfferType::TEN_PERCENT_DISCOUNT
      quantity = @product_quantities[p]
      unit_price = catalog.unit_price(p)
      percent = offer.argument
      discount_amount = quantity * unit_price * percent / 100.0
      discount = Discount.new(p, "#{percent}% off", discount_amount)
    when SpecialOfferType::THREE_FOR_TWO
      quantity = @product_quantities[p]
      unit_price = catalog.unit_price(p)
      quantity_as_int = quantity.to_i
      x = 3
      y = 2
      number_of_x = quantity_as_int / x
      if quantity_as_int >= x
        total = (number_of_x * y * unit_price) + quantity_as_int % x * unit_price
        discount_amount = quantity * unit_price - total
        discount = Discount.new(p, "#{x} for #{y}", discount_amount)
      end
    when SpecialOfferType::TWO_FOR_AMOUNT
      quantity = @product_quantities[p]
      unit_price = catalog.unit_price(p)
      quantity_as_int = quantity.to_i
      x = 2
      amount = offer.argument
      if quantity_as_int >= x
        total = amount * (quantity_as_int / x) + quantity_as_int % x * unit_price
        discount_amount = unit_price * quantity - total
        discount = Discount.new(p, "#{x} for #{amount}", discount_amount)
      end
      number_of_x = quantity_as_int / x
    when SpecialOfferType::FIVE_FOR_AMOUNT
      quantity = @product_quantities[p]
      unit_price = catalog.unit_price(p)
      quantity_as_int = quantity.to_i
      x = 5
      amount = offer.argument
      number_of_x = quantity_as_int / x
      if quantity_as_int >= x
        total = amount * number_of_x + quantity_as_int % x * unit_price
        discount_amount = unit_price * quantity - total
        discount = Discount.new(p, "#{x} for #{amount}", discount_amount)
      end
    end

    discount
  end
end
