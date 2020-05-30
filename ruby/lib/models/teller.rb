class Teller
  def initialize
    @offers = {}
    @items = []
  end

  def add_item_quantity(product, quantity)
    @items << ReceiptItem.new(product, quantity)
  end

  def add_special_offer(offer_type, product, argument)
    @offers[product] = Offer.new(offer_type, product, argument)
  end

  def receipt
    receipt = Receipt.new

    @items.each { |item| receipt.add_receipt_item(item) }

    product_quantities.each do |product, quantity|
      discount = find_discount(product, quantity)
      next unless discount

      receipt.add_discount(discount)
    end

    receipt
  end

  private

  def find_discount(product, quantity)
    description, discount_amount = DiscountCalculator.get_discount(
      @offers[product],
      quantity,
      product.unit_price
    )
    return unless discount_amount

    Discount.new(product, description, discount_amount)
  end

  def product_quantities
    @items.group_by(&:product).transform_values do |items|
      items.sum(&:quantity)
    end
  end
end
