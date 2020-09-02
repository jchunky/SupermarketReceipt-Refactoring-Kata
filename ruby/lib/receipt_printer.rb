class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    total_price = format_price(receipt.total_price)

    [
      receipt.items.map(&method(:format_receipt_item)),
      receipt.discounts.map(&method(:format_discount)),
      "",
      format_line("Total: ", total_price),
    ].flatten.join("\n")
  end

  def format_receipt_item(item)
    product_name = item.product.name
    total_price = format_price(item.total_price)

    unit_price = format_price(item.price)
    quantity = format_quantity(item)
    subtotal = ("  " + unit_price + " * " + quantity if item.quantity != 1)

    [
      format_line(product_name, total_price),
      subtotal,
    ].compact
  end

  def format_discount(discount)
    product_name = discount.product.name
    discount_amount = format_price(discount.discount_amount)
    discount_description = discount.description

    format_line("#{discount_description}(#{product_name})", "-#{discount_amount}")
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
