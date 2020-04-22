class ShoppingCart
  attr_reader :items, :product_quantities

  def initialize
    @items = []
    @product_quantities = {}
  end

  def add_item(product)
    add_item_quantity(product, 1.0)
  end

  def add_item_quantity(product, quantity)
    @items << ProductQuantity.new(product, quantity)
    product_quantities[product] =
      if @product_quantities.key?(product)
        product_quantities[product] + quantity
      else
        quantity
      end
  end

  def handle_offers(receipt, offers, catalog)
    @product_quantities.each_key do |p|
      quantity = @product_quantities[p]
      next unless offers.key?(p)

      offer = offers[p]
      unit_price = catalog.unit_price(p)
      discount = nil

      quantity_as_int = quantity.to_i
      case offer.offer_type
      when SpecialOfferType::THREE_FOR_TWO
        x = 3
        y = 2
        number_of_x = quantity_as_int / x
        if quantity_as_int >= x
          discount_amount = quantity * unit_price - ((number_of_x * y * unit_price) + quantity_as_int % x * unit_price)
          discount = Discount.new(p, "#{x} for #{y}", discount_amount)
        end
      when SpecialOfferType::TWO_FOR_AMOUNT
        x = 2
        amount = offer.argument
        if quantity_as_int >= 2
          total = amount * (quantity_as_int / x) + quantity_as_int % 2 * unit_price
          discount_amount = unit_price * quantity - total
          discount = Discount.new(p, "#{x} for #{amount}", discount_amount)
        end
      when SpecialOfferType::FIVE_FOR_AMOUNT
        x = 5
        amount = offer.argument
        number_of_x = quantity_as_int / x
        discount_amount = unit_price * quantity - (amount * number_of_x + quantity_as_int % 5 * unit_price)
        discount = Discount.new(p, "#{x} for #{amount}", discount_amount)
      when SpecialOfferType::TEN_PERCENT_DISCOUNT
        percentage = offer.argument
        discount_amount = quantity * unit_price * offer.argument / 100.0
        discount = Discount.new(p, "#{percentage}% off", discount_amount)
      end

      receipt.add_discount(discount) if discount
    end
  end
end
