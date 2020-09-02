class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    result = []
    result << receipt.items.map(&method(:format_receipt_item))
    result << receipt.discounts.map do |discount|
      format_discount(discount)
    end
    result << ""
    price = format_price(receipt.total_price)
    total = "Total: "
    result << format_line(total, price)

    result.flatten.join("\n")
  end

  def format_receipt_item(item)
    price = format_price(item.total_price)
    quantity = format_quantity(item)
    name = item.product.name
    unit_price = format_price(item.price)

    [
      format_line(name, price),
      ("  " + unit_price + " * " + quantity if item.quantity != 1),
    ].compact
  end

  def format_discount(discount)
    product = discount.product.name
    price = format_price(discount.discount_amount)
    description = discount.description
    format_line("#{description}(#{product})", "-#{price}")
  end

  def format_line(left, right)
    left + right.rjust(@columns - left.size)
  end

  def format_price(price)
    format("%.2f", price)
  end

  def format_quantity(item)
    case item.product.unit
    when ProductUnit::EACH
      format("%x", item.quantity.to_i)
    when ProductUnit::KILO
      format("%.3f", item.quantity)
    else
      raise "Unhandled ProductUnit: #{item.product.unit}"
    end
  end
end
