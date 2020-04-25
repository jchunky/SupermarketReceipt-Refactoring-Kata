class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    [
      receipt.items.map(&method(:format_receipt_item)),
      receipt.discounts.map(&method(:format_discount)),
      "\n",
      format_line("Total:", format_price(receipt.total_price)),
    ].join
  end

  private

  def format_receipt_item(item)
    price = format_price(item.total_price)
    quantity = format_quantity(item)
    name = item.product.name
    unit_price = format_price(item.price)
    result = format_line(name, price) + "\n"
    result << "  " + unit_price + " * " + quantity + "\n" if item.quantity != 1
    result
  end

  def format_discount(discount)
    product = discount.product.name
    price = format_price(discount.discount_amount)
    description = discount.description
    format_line("#{description}(#{product})", "-#{price}") + "\n"
  end

  def format_line(left, right)
    left + right.rjust(@columns - left.size)
  end

  def format_price(price)
    "%.2f" % price
  end

  def format_quantity(item)
    if ProductUnit::EACH == item.product.unit
      "%x" % item.quantity.to_i
    else
      "%.3f" % item.quantity
    end
  end
end
