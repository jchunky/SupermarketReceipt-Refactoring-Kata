class Teller
  attr_reader :items

  def initialize(catalog)
    @catalog = catalog
    @offers = {}
    @items = []
  end

  def add_item(product)
    add_item_quantity(product, 1.0)
  end

  def add_item_quantity(product, quantity)
    items << ProductQuantity.new(product, quantity)
  end

  def add_special_offer(offer_type, product, argument)
    @offers[product] = Offer.new(offer_type, product, argument)
  end

  def handle_offers(receipt, offers, catalog)
    product_quantities.each do |product, quantity|
      offer = offers[product]
      unit_price = catalog.unit_price(product)
      description, discount_amount = get_discount(offer, quantity, unit_price)
      next unless discount_amount

      discount = Discount.new(product, description, discount_amount)
      receipt.add_discount(discount)
    end
  end

  def receipt
    receipt = Receipt.new

    items.each do |product_quantity|
      receipt.add_receipt_item(build_receipt_item(product_quantity))
    end

    handle_offers(receipt, @offers, @catalog)

    receipt
  end

  private

  def build_receipt_item(product_quantity)
    product = product_quantity.product
    quantity = product_quantity.quantity
    unit_price = @catalog.unit_price(product)

    ReceiptItem.new(product, quantity, unit_price)
  end

  def get_discount(offer, quantity, unit_price)
    return nil unless offer

    case offer.offer_type
    when :percent_discount
      percent = offer.argument
      discount_amount = quantity * unit_price * percent / 100.0
      ["#{percent}% off", discount_amount]
    when :three_for_two
      quantity_as_int = quantity.to_i
      x = 3
      y = 2
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = (number_of_x * y * unit_price) + quantity_as_int % x * unit_price
      discount_amount = quantity * unit_price - total
      ["#{x} for #{y}", discount_amount]
    when :two_for_amount
      quantity_as_int = quantity.to_i
      x = 2
      amount = offer.argument
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = amount * number_of_x + quantity_as_int % x * unit_price
      discount_amount = unit_price * quantity - total
      ["#{x} for #{amount}", discount_amount]
    when :five_for_amount
      quantity_as_int = quantity.to_i
      x = 5
      amount = offer.argument
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = amount * number_of_x + quantity_as_int % x * unit_price
      discount_amount = unit_price * quantity - total
      ["#{x} for #{amount}", discount_amount]
    else
      raise "Unknown offer type: #{offer.offer_type}"
    end
  end

  def product_quantities
    items.group_by(&:product).transform_values { |items| items.sum(&:quantity) }
  end
end
