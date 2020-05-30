class Teller
  def initialize(catalog)
    @catalog = catalog
    @offers = {}
    @items = []
  end

  def add_item_quantity(product, quantity)
    @items << ProductQuantity.new(product, quantity)
  end

  def add_special_offer(offer_type, product, argument)
    @offers[product] = Offer.new(offer_type, product, argument)
  end

  def receipt
    receipt = Receipt.new

    @items.each do |product_quantity|
      receipt.add_receipt_item(build_receipt_item(product_quantity))
    end

    product_quantities.each do |product, quantity|
      offer = @offers[product]
      unit_price = @catalog.unit_price(product)
      description, discount_amount = DiscountCalculator.get_discount(
        offer,
        quantity,
        unit_price
      )
      next unless discount_amount

      discount = Discount.new(product, description, discount_amount)
      receipt.add_discount(discount)
    end

    receipt
  end

  private

  def build_receipt_item(product_quantity)
    product = product_quantity.product
    quantity = product_quantity.quantity
    unit_price = @catalog.unit_price(product)

    ReceiptItem.new(product, quantity, unit_price)
  end

  def product_quantities
    @items.group_by(&:product).transform_values do |items|
      items.sum(&:quantity)
    end
  end
end
