class Teller
  def initialize(catalog)
    @catalog = catalog
    @offers = {}
  end

  def add_special_offer(offer_type, product, argument)
    @offers[product] = Offer.new(offer_type, product, argument)
  end

  def checks_out_articles_from(the_cart)
    receipt = Receipt.new
    the_cart.items.each do |product_quantity|
      receipt.add_receipt_item(create_receipt_item(product_quantity))
    end
    the_cart.handle_offers(receipt, @offers, @catalog)
    receipt
  end

  private

  def create_receipt_item(product_quantity)
    product = product_quantity.product
    quantity = product_quantity.quantity
    unit_price = @catalog.unit_price(product)
    total_price = quantity * unit_price
    ReceiptItem.new(product, quantity, unit_price, total_price)
  end
end
