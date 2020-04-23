class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    result = ''
    receipt.items.each do |item|
      price = format_price(item.total_price)
      quantity = format_quantity(item)
      product = item.product.name
      unit_price = format_price(item.price)

      whitespace_size = @columns - product.size - price.size
      line = product
      line += whitespace(whitespace_size) + price + "\n"
      line += '  ' + unit_price + ' * ' + quantity + "\n" if item.quantity != 1

      result << line
    end
    receipt.discounts.each do |discount|
      product = discount.product.name
      price = format_price(discount.discount_amount)
      description = discount.description

      result << description + '(' + product + ')'
      result << whitespace(@columns - 3 - product.size - description.size - price.size)
      result << '-' + price

      result << "\n"
    end
    result << "\n"
    price = format_price(receipt.total_price.to_f)

    result << 'Total: '
    result << whitespace(@columns - 'Total: '.size - price.size)
    result << price

    result
  end

  private

  def format_price(price)
    '%.2f' % price
  end

  def format_quantity(item)
    if ProductUnit::EACH == item.product.unit
      '%x' % item.quantity.to_i
    else
      '%.3f' % item.quantity
    end
  end

  def whitespace(length)
    ' ' * length
  end
end
