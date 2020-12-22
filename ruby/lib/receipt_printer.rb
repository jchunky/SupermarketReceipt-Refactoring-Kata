class ReceiptPrinter
  attr_reader :columns

  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    [
      receipt.items.map(&method(:format_item)),
      receipt.discounts.map(&method(:format_discount)),
      "",
      format_line("Total: ", format_price(receipt.total_price)),
    ].flatten.compact.join("\n")
  end

  private

  def format_item(item)
    [
      format_line(item.product.name, format_price(item.total_price)),
      (format("  %s * %s", format_price(item.price), format_quantity(item)) if item.quantity != 1),
    ]
  end

  def format_discount(discount)
    discount_amount = format_price(discount.discount_amount)
    description = format("%s(%s)", discount.description, discount.product.name)
    format_line(description, "-#{discount_amount}")
  end

  def format_line(left, right)
    [left, right.rjust(columns - left.size)].join
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
    end
  end
end
