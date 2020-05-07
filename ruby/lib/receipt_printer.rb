class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    total_price = format_price(receipt.total_price)

    [
      receipt.items.map(&method(:item_lines)),
      receipt.discounts.map(&method(:discount_lines)),
      "",
      format_line("Total:", total_price),
    ].join("\n")
  end

  private

  def item_lines(item)
    price = format_price(item.total_price)
    quantity = format_quantity(item)
    product = item.product.name
    unit_price = format_price(item.price)
    [
      format_line(product, price),
      ("  #{unit_price} * #{quantity}" if item.quantity != 1),
    ].compact
  end

  def discount_lines(discount)
    product = discount.product.name
    discount_amount = format_price(discount.discount_amount)
    description = discount.description
    format_line("#{description}(#{product})", "-#{discount_amount}")
  end

  def format_price(price)
    format("%.2f", price)
  end

  def format_line(left, right)
    left + right.rjust(@columns - left.size)
  end

  def format_quantity(item)
    case item.product.unit
    when ProductUnit::EACH then format("%x", item.quantity)
    when ProductUnit::KILO then format("%.3f", item.quantity)
    else raise "Unexpected ProductUnit: #{item.product.unit}"
    end
  end
end
