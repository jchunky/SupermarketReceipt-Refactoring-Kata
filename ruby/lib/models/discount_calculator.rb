class DiscountCalculator
  def self.get_discount(offer, product, quantity)
    return unless offer

    unit_price = product.unit_price

    case offer.offer_type
    when :percent_discount
      percent = offer.argument
      discount_amount = quantity * unit_price * percent / 100.0
      description = "#{percent}% off"
    when :three_for_two
      quantity_as_int = quantity.to_i
      x = 3
      y = 2
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = (number_of_x * y * unit_price) + quantity_as_int % x * unit_price
      discount_amount = quantity * unit_price - total
      description = "#{x} for #{y}"
    when :two_for_amount
      quantity_as_int = quantity.to_i
      x = 2
      amount = offer.argument
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = amount * number_of_x + quantity_as_int % x * unit_price
      discount_amount = unit_price * quantity - total
      description = "#{x} for #{amount}"
    when :five_for_amount
      quantity_as_int = quantity.to_i
      x = 5
      amount = offer.argument
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = amount * number_of_x + quantity_as_int % x * unit_price
      discount_amount = unit_price * quantity - total
      description = "#{x} for #{amount}"
    else
      raise "Unknown offer type: #{offer_type}"
    end

    Discount.new(product, description, discount_amount)
  end
end
