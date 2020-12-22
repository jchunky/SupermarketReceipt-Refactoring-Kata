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
    product_quantities = the_cart.items
    product_quantities.each do |pq|
      p = pq.product
      quantity = pq.quantity
      unit_price = @catalog.unit_price(p)
      price = quantity * unit_price
      item = ReceiptItem.new(p, quantity, unit_price, price)
      receipt.add_item(item)
    end
    the_cart.handle_offers(receipt, @offers, @catalog)

    receipt
  end
end
