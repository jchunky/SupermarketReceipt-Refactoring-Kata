class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    result = []
    receipt.items.each do |item|
      price = format_price(item.total_price)
      quantity = format_quantity(item)
      product = item.product.name
      unit_price = format_price(item.price)
      result << format_line(product, price)
      result << "  #{unit_price} * #{quantity}" if item.quantity != 1
    end
    receipt.discounts.each do |discount|
      product = discount.product.name
      discount_amount = format_price(discount.discount_amount)
      description = discount.description
      result << format_line("#{description}(#{product})", "-#{discount_amount}")
    end
    total_price = format_price(receipt.total_price)
    result << ""
    result << format_line("Total:", total_price)
    result.join("\n")
  end

  private

  def format_price(price)
    format("%.2f", price)
  end

  def format_line(left, right)
    left + right.rjust(@columns - left.size)
  end

  def format_quantity(item)
    ProductUnit::EACH == item.product.unit ? "%x" % item.quantity.to_i : "%.3f" % item.quantity
  end
end
