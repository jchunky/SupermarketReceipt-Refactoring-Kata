class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    result = ""

    receipt.items.each do |item|
      result << format_receipt_item(item)
    end

    receipt.discounts.each do |discount|
      result << format_discount(discount)
      result << "\n"
    end

    result << "\n"
    result << format_line("Total:", format_price(receipt.total_price))
    result
  end

  private

  def format_receipt_item(item)
    price = format_price(item.total_price)
    quantity = format_quantity(item)
    name = item.product.name
    unit_price = format_price(item.price)

    line = format_line(name, price) + "\n"
    line += "  #{unit_price} * #{quantity}\n" if item.quantity != 1
    line
  end

  def format_discount(discount)
    product = discount.product.name
    price_presentation = format_price(discount.discount_amount)
    description = discount.description

    format_line(
      "#{description}(#{product})",
      "-#{price_presentation}"
    )
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
