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

  def format_receipt_item(receipt_item)
    price = format_price(receipt_item.total_price)
    quantity = format_quantity(receipt_item)
    product = receipt_item.product.name
    unit_price = format_price(receipt_item.unit_price)

    [
      format_line(product, price),
      ("  #{unit_price} * #{quantity}" if receipt_item.quantity != 1),
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
    case item.product.unit
    when :each
      format("%x", item.quantity)
    when :kilo
      format("%.3f", item.quantity)
    else
      raise "Unknown item unit: #{item.product.unit}"
    end
  end
end
