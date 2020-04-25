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
    the_cart.items.map(&method(:build_receipt_item)).each do |receipt_item|
      receipt.add_product(receipt_item)
    end
    the_cart.handle_offers(receipt, @offers, @catalog)
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
