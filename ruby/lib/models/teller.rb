class Teller
  def initialize(catalog)
    @catalog = catalog
    @offers = {}
  end

  def add_special_offer(offer_type, product, argument)
    @offers[product] = Offer.new(offer_type, product, argument)
  end

  def checks_out_articles_from(cart)
    receipt = build_receipt(cart)
    cart.handle_offers(receipt, @offers, @catalog)
    receipt
  end

  private

  def build_receipt(cart)
    receipt = Receipt.new
    cart.items.each do |product_quantity|
      receipt.add_product(build_receipt_item(product_quantity))
    end
    receipt
  end

  def build_receipt_item(product_quantity)
    product = product_quantity.product
    quantity = product_quantity.quantity
    unit_price = @catalog.unit_price(product)
    price = quantity * unit_price
    ReceiptItem.new(product, quantity, unit_price, price)
  end
end
