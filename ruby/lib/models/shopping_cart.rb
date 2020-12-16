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

  def handle_offers(receipt, offers, catalog)
    product_quantities
      .keys
      .select { |p| offers.key?(p) }
      .map { |p| calculate_discount(offers, catalog, p) }
      .compact
      .each { |discount| receipt.add_discount(discount) }
  end

  private

  def calculate_discount(offers, catalog, p)
    offer = offers[p]
    quantity = product_quantities[p]
    unit_price = catalog.unit_price(p)
    regular_price = quantity * unit_price

    case offer.offer_type
    when SpecialOfferType::THREE_FOR_TWO
      x = 3
      y = 2
      return unless quantity >= x

      total = (quantity / x * y + quantity % x) * unit_price
      discount_amount = regular_price - total
      Discount.new(p, "#{x} for #{y}", discount_amount)
    when SpecialOfferType::TWO_FOR_AMOUNT
      x = 2
      y = offer.argument
      return unless quantity >= x

      total = quantity / x * y + quantity % x * unit_price
      discount_amount = regular_price - total
      Discount.new(p, "#{x} for #{y}", discount_amount)
    when SpecialOfferType::FIVE_FOR_AMOUNT
      x = 5
      y = offer.argument
      return unless quantity >= x

      total = quantity / x * y + quantity % x * unit_price
      discount_amount = regular_price - total
      Discount.new(p, "#{x} for #{y}", discount_amount)
    when SpecialOfferType::TEN_PERCENT_DISCOUNT
      discount_percentage = offer.argument
      discount_amount = regular_price * discount_percentage / 100.0
      Discount.new(p, "#{discount_percentage}% off", discount_amount)
    end
  end

  def product_quantities
    @product_quantities ||= items.group_by(&:product).transform_values { |pq| pq.sum(&:quantity) }
  end
end
