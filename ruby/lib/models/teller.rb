class Teller
  attr_reader :offers, :receipt_items

  def initialize
    @offers = {}
    @receipt_items = []
  end

  def add_item_quantity(product, quantity)
    receipt_items << ReceiptItem.new(product, quantity)
  end

  def add_special_offer(offer_type, product, argument)
    offers[product] = Offer.new(offer_type, product, argument)
  end

  def receipt
    Receipt.new(receipt_items, discounts)
  end

  private

  def discounts
    receipt_items
      .group_by(&:product)
      .transform_values { |items| items.sum(&:quantity) }
      .map(&method(:find_discount))
      .compact
  end

  def find_discount(product, quantity)
    DiscountCalculator.get_discount(offers[product], product, quantity)
  end
end
