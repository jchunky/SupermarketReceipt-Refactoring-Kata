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
        discount_amount = quantity * unit_price - ((number_of_x * 2 * unit_price) + quantity_as_int % 3 * unit_price)
        discount = Discount.new(p, "3 for 2", discount_amount)
      end
    when SpecialOfferType::TEN_PERCENT_DISCOUNT
      quantity = @product_quantities[p]
      unit_price = catalog.unit_price(p)
      quantity_as_int = quantity.to_i
      x = 1
      number_of_x = quantity_as_int / x
      discount = Discount.new(p, offer.argument.to_s + "% off", quantity * unit_price * offer.argument / 100.0 )
    when SpecialOfferType::TWO_FOR_AMOUNT
      quantity = @product_quantities[p]
      unit_price = catalog.unit_price(p)
      quantity_as_int = quantity.to_i
      x = 2
      if quantity_as_int >= 2
        total = offer.argument * (quantity_as_int / x) + quantity_as_int % 2 * unit_price
        discount_n = unit_price * quantity - total
        discount = Discount.new(p, "2 for " + offer.argument.to_s, discount_n)
      end

      number_of_x = quantity_as_int / x
    when SpecialOfferType::FIVE_FOR_AMOUNT
      quantity = @product_quantities[p]
      unit_price = catalog.unit_price(p)
      quantity_as_int = quantity.to_i
      x = 5
      number_of_x = quantity_as_int / x
      if quantity_as_int >= 5
        discount_total = unit_price * quantity - (offer.argument * number_of_x + quantity_as_int % 5 * unit_price)
        discount = Discount.new(p, x.to_s + " for " + offer.argument.to_s, discount_total)
      end
    end

    discount
  end
end
