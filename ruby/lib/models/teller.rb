class Teller
  attr_reader :offers, :catalog

  def initialize(catalog)
    @catalog = catalog
    @offers = {}
  end

  def add_special_offer(offer_type, product, argument)
    offers[product] = Offer.new(offer_type, product, argument)
  end

  def checks_out_articles_from(cart)
    receipt = Receipt.new

    cart.items
      .map { |pq| build_receipt_item(pq) }
      .each { |item| receipt.add_item(item) }

    cart.handle_offers(receipt, offers, catalog)

    receipt
  end

  private

  def build_receipt_item(product_quantity)
    product = product_quantity.product
    quantity = product_quantity.quantity
    unit_price = catalog.unit_price(product)
    total_price = quantity * unit_price
    ReceiptItem.new(product, quantity, unit_price, total_price)
  end
end
