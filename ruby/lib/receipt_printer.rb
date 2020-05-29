class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    [
      receipt.items.map(&method(:format_receipt_item)),
      receipt.discounts.map(&method(:format_discount)),
      "",
      format_line("Total:", format_price(receipt.total_price)),
    ].join("\n")
  end

  private

  def format_receipt_item(item)
    price = format_price(item.total_price)
    quantity = format_quantity(item)
    product = item.product.name
    unit_price = format_price(item.price)

    [
      format_line(product, price),
      ("  #{unit_price} * #{quantity}" if item.quantity != 1),
    ].compact
  end

  def format_discount(discount)
    product = discount.product.name
    discount_amount = format_price(discount.discount_amount)
    description = discount.description

    format_line("#{description}(#{product})", "-#{discount_amount}")
  end

  def format_line(left, right)
    left + right.rjust(@columns - left.size)
  end

  def format_price(price)
    format("%.2f", price)
  end

  def format_quantity(item)
    if ProductUnit::EACH == item.product.unit
      format("%x", item.quantity)
    else
      format("%.3f", item.quantity)
    end
  end
end
