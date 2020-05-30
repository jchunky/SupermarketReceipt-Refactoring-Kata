class DiscountCalculator
  def self.get_discount(offer, quantity, unit_price)
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
end
