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
    product_quantities.keys
      .select { |pq| offers.key?(pq) }
      .map { |pq| build_discount(catalog, offers, pq) }
      .compact
      .each { |discount| receipt.add_discount(discount) }
  end

  private

  def build_discount(catalog, offers, product_quantity)
    quantity = product_quantities[product_quantity]

    offer = offers[product_quantity]
    unit_price = catalog.unit_price(product_quantity)
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
          product_quantity,
          "2 for #{offer.argument}",
          discount_n
        )
      end

    end
    x = 5 if offer.offer_type == SpecialOfferType::FIVE_FOR_AMOUNT
    number_of_x = quantity_as_int / x
    if offer.offer_type == SpecialOfferType::THREE_FOR_TWO && quantity_as_int > 2
      discount_amount = quantity * unit_price - ((number_of_x * 2 * unit_price) + quantity_as_int % 3 * unit_price)
      discount = Discount.new(product_quantity, "3 for 2", discount_amount)
    end
    if offer.offer_type == SpecialOfferType::TEN_PERCENT_DISCOUNT
      discount = Discount.new(
        product_quantity,
        "#{offer.argument}% off",
        quantity * unit_price * offer.argument / 100.0
      )
    end
    if offer.offer_type == SpecialOfferType::FIVE_FOR_AMOUNT && quantity_as_int >= 5
      discount_total = unit_price * quantity - (offer.argument * number_of_x + quantity_as_int % 5 * unit_price)
      discount = Discount.new(
        product_quantity,
        "#{x} for #{offer.argument}",
        discount_total
      )
    end
    discount
  end
end
