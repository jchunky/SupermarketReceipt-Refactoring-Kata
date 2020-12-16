class ShoppingCart
  attr_reader :items

  def initialize
    @items = []
  end

  def add_item(product)
    add_item_quantity(product, 1.0)
  end

  def add_item_quantity(product, quantity)
    items << ProductQuantity.new(product, quantity)
  end

  def product_quantities
    @product_quantities ||= items.group_by(&:product).transform_values { |pq| pq.sum(&:quantity) }
  end

  def handle_offers(receipt, offers, catalog)
    product_quantities.each_key do |p|
      next unless offers.key?(p)

      discount = calculate_discount(offers, catalog, p)

      receipt.add_discount(discount) if discount
    end
  end

  def calculate_discount(offers, catalog, p)
    quantity = product_quantities[p]
    offer = offers[p]
    unit_price = catalog.unit_price(p)
    quantity_as_int = quantity.to_i
    discount = nil
    x = 1
    case offer.offer_type
    when SpecialOfferType::THREE_FOR_TWO
      x = 3

    when SpecialOfferType::TWO_FOR_AMOUNT
      x = 2
      if quantity_as_int >= 2
        total = offer.argument * (quantity_as_int / x) + quantity_as_int % 2 * unit_price
        discount_n = unit_price * quantity - total
        discount = Discount.new(
          p,
          "2 for #{offer.argument}",
          discount_n
        )
      end

    end
    x = 5 if offer.offer_type == SpecialOfferType::FIVE_FOR_AMOUNT
    number_of_x = quantity_as_int / x
    if offer.offer_type == SpecialOfferType::THREE_FOR_TWO && quantity_as_int > 2
      discount_amount = quantity * unit_price - ((number_of_x * 2 * unit_price) + quantity_as_int % 3 * unit_price)
      discount = Discount.new(p, "3 for 2", discount_amount)
    end
    if offer.offer_type == SpecialOfferType::TEN_PERCENT_DISCOUNT
      discount = Discount.new(
        p,
        "#{offer.argument}% off",
        quantity * unit_price * offer.argument / 100.0
      )
    end
    if offer.offer_type == SpecialOfferType::FIVE_FOR_AMOUNT && quantity_as_int >= 5
      discount_total = unit_price * quantity - (offer.argument * number_of_x + quantity_as_int % 5 * unit_price)
      discount = Discount.new(
        p,
        "#{x} for #{offer.argument}",
        discount_total
      )
    end
    discount
  end
end
