class Teller
  def initialize(catalog)
    @catalog = catalog
    @offers = {}
  end

  def add_special_offer(offer_type, product, argument)
    @offers[product] = Offer.new(offer_type, product, argument)
  end

  def checks_out_articles_from(shopping_cart)
    receipt = Receipt.new

    shopping_cart.items.each do |product_quantity|
      receipt.add_product(build_receipt_item(product_quantity))
    end

    shopping_cart.handle_offers(receipt, @offers, @catalog)

    receipt
  end

  private

  def build_receipt_item(product_quantity)
    product = product_quantity.product
    quantity = product_quantity.quantity
    unit_price = @catalog.unit_price(product)

    receipt_item = ReceiptItem.new(product, quantity, unit_price)
  end
end
