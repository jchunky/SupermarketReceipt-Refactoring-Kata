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

      discount = get_discount(receipt, offers, catalog, p)

      receipt.add_discount(discount) if discount
    end
  end

  def get_discount(receipt, offers, catalog, p)

    offer = offers[p]

    case offer.offer_type
    when SpecialOfferType::THREE_FOR_TWO
      quantity = @product_quantities[p]
      unit_price = catalog.unit_price(p)
      quantity_as_int = quantity.to_i
      x = 3
      number_of_x = quantity_as_int / x
      if  quantity_as_int > 2
        total = ((number_of_x * 2 * unit_price) + quantity_as_int % 3 * unit_price)
        discount_total = quantity * unit_price - total
        discount = Discount.new(p, "3 for 2", discount_total)
      end
    when SpecialOfferType::TEN_PERCENT_DISCOUNT
      quantity = @product_quantities[p]
      unit_price = catalog.unit_price(p)
      discount_percentage = offer.argument
      discount_description = "#{discount_percentage}% off"
      total = discount_percentage / 100.0
      discount_total = quantity * unit_price * total
      discount = Discount.new(p, discount_description, discount_total)
    when SpecialOfferType::TWO_FOR_AMOUNT
      quantity = @product_quantities[p]
      unit_price = catalog.unit_price(p)
      quantity_as_int = quantity.to_i
      x = 2
      y = offer.argument
      if quantity_as_int >= 2
        total = offer.argument * (quantity_as_int / x) + quantity_as_int % 2 * unit_price
        discount_total = unit_price * quantity - total
        discount_description = "#{x} for #{y}"
        discount = Discount.new(p, discount_description, discount_total)
      end

      number_of_x = quantity_as_int / x
    when SpecialOfferType::FIVE_FOR_AMOUNT
      quantity = @product_quantities[p]
      unit_price = catalog.unit_price(p)
      quantity_as_int = quantity.to_i
      x = 5
      y = offer.argument
      number_of_x = quantity_as_int / x
      if quantity_as_int >= 5
        total = (offer.argument * number_of_x + quantity_as_int % 5 * unit_price)
        discount_total = unit_price * quantity - total
        discount_description = "#{x} for #{y}"
        discount = Discount.new(p, discount_description, discount_total)
      end
    end

    discount
  end
end
