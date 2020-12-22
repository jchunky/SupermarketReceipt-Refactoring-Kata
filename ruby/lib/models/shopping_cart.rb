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
    offer = offers[product_quantity]
    quantity = product_quantities[product_quantity]
    unit_price = catalog.unit_price(product_quantity)
    quantity_as_int = quantity.to_i

    case offer.offer_type
    when SpecialOfferType::THREE_FOR_TWO
      x = 3
      y = 2
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = number_of_x * y * unit_price + quantity_as_int % x * unit_price
      discount_amount = quantity * unit_price - total
      Discount.new(product_quantity, "#{x} for #{y}", discount_amount)
    when SpecialOfferType::TEN_PERCENT_DISCOUNT
      percentage_discount = offer.argument
      total = percentage_discount / 100.0
      discount_total = quantity * unit_price * total
      Discount.new(product_quantity, "#{percentage_discount}% off", discount_total)
    when SpecialOfferType::TWO_FOR_AMOUNT
      x = 2
      number_of_x = quantity_as_int / x
      group_amount = offer.argument
      return unless quantity_as_int >= x

      total = group_amount * number_of_x + quantity_as_int % x * unit_price
      discount_total = unit_price * quantity - total
      Discount.new(product_quantity, "#{x} for #{group_amount}", discount_total)
    when SpecialOfferType::FIVE_FOR_AMOUNT
      x = 5
      number_of_x = quantity_as_int / x
      group_amount = offer.argument
      return unless quantity_as_int >= x

      total = group_amount * number_of_x + quantity_as_int % x * unit_price
      discount_total = unit_price * quantity - total
      Discount.new(product_quantity, "#{x} for #{group_amount}", discount_total)
    end
  end
end
