class Teller
  attr_reader :offers, :items

  def initialize
    @offers = {}
    @items = []
  end

  def add_item_quantity(product, quantity)
    items << ReceiptItem.new(product, quantity)
  end

  def add_special_offer(offer_type, product, argument)
    offers[product] = Offer.new(offer_type, product, argument)
  end

  def receipt
    Receipt.new(items, discounts)
  end

  private

  def discounts
    items
      .group_by(&:product)
      .transform_values { |items| items.sum(&:quantity) }
      .map(&method(:find_discount))
      .compact
  end

  def find_discount(product, quantity)
    offer = offers[product]
    description, discount_amount = DiscountCalculator.get_discount(
      offer,
      product.unit_price,
      quantity
    )
    return unless discount_amount

    Discount.new(product, description, discount_amount)
  end
end
