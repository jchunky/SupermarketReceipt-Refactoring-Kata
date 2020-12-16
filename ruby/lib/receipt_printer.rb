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
      format_line("Total:", format_price(receipt.total_price)),
    ].flatten.join("\n")
  end

  private

  def format_item(item)
    price = format_price(item.total_price)
    quantity = format_quantity(item)
    name = item.product.name
    unit_price = format_price(item.price)
    [
      format_line(name, price),
      (format("  %s * %s", unit_price, quantity) if item.quantity != 1),
    ].compact
  end

  def format_discount(discount)
    description = format("%s(%s)", discount.description, discount.product.name)
    discount_amount = format("-%s", format_price(discount.discount_amount))
    format_line(description, discount_amount)
  end

  def format_line(left, right)
    [left, right.rjust(columns - left.size)].join
  end

  def format_price(price)
    format("%.2f", price)
  end

  def format_quantity(item)
    case item.product.unit
    when ProductUnit::EACH then format("%x", item.quantity)
    when ProductUnit::KILO then format("%.3f", item.quantity)
    end
  end
end
