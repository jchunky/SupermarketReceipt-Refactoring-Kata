class DiscountCalculator
  def self.get_discount(offer, quantity)
    return unless offer

    unit_price = offer.product.unit_price

    case offer.offer_type
    when :percent_discount
      percent = offer.argument
      discount_amount = quantity * unit_price * percent / 100
      description = format("%.f%% off", percent)
    when :three_for_two
      quantity_as_int = quantity.to_i
      x = 3
      y = 2
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = (number_of_x * y * unit_price) + quantity_as_int % x * unit_price
      discount_amount = quantity * unit_price - total
      description = format("%d for %d", x, y)
    when :two_for_amount
      quantity_as_int = quantity.to_i
      x = 2
      amount = offer.argument
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = amount * number_of_x + quantity_as_int % x * unit_price
      discount_amount = unit_price * quantity - total
      description = format("%d for %.2f", x, amount)
    when :five_for_amount
      quantity_as_int = quantity.to_i
      x = 5
      amount = offer.argument
      number_of_x = quantity_as_int / x
      return unless quantity_as_int >= x

      total = amount * number_of_x + quantity_as_int % x * unit_price
      discount_amount = unit_price * quantity - total
      description = format("%d for %.2f", x, amount)
    else
      raise "Unknown offer type: #{offer_type}"
    end

    Discount.new(offer.product, description, discount_amount.round(2))
  end
end
