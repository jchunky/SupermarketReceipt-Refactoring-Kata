class ReceiptPrinter
  attr_reader :columns

  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    result = []
    receipt.items.each do |item|
      result << format_item(item)
    end
    receipt.discounts.each do |discount|
      result << format_discount(discount)
      result << "\n"
    end
    result << "\n"
    result << format_line("Total: ", format_price(receipt.total_price))
    result.join
  end

  private

  def format_item(item)
    price = format_price(item.total_price)
    quantity = format_quantity(item)
    name = item.product.name
    unit_price = format_price(item.price)
    line = format_line(name, price)
    line += "\n"
    line += "  #{unit_price} * #{quantity}\n" if item.quantity != 1
    line
  end

  def format_price(price)
    "%.2f" % price
  end

  def format_line(left, right)
    [left, right.rjust(columns - left.size)].join
  end

  def format_quantity(item)
    case item.product.unit
    when ProductUnit::EACH
      "%x" % item.quantity.to_i
    when ProductUnit::KILO
      "%.3f" % item.quantity
    end
  end

  def format_discount(discount)
    price_presentation = format_price(discount.discount_amount)
    discount_description = "#{discount.description}(#{discount.product.name})"
    format_line(discount_description, "-#{price_presentation}")
  end
end
