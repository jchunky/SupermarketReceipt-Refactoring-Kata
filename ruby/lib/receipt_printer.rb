class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    [
      receipt.items.map(&method(:format_receipt_item)).join,
      receipt.discounts.map(&method(:format_discount)).join,
      "\n",
      format_line('Total:', format_price(receipt.total_price))
    ].join
  end

  private

  def format_receipt_item(item)
    product_name = item.product.name
    total_price = format_price(item.total_price)
    unit_price = format_price(item.price)
    quantity = format_quantity(item)

    [
      format_line(product_name, total_price) + "\n",
      ("  #{unit_price} * #{quantity}\n" if item.quantity != 1)
    ].compact.join
  end

  def format_discount(discount)
    description = "#{discount.description}(#{discount.product.name})"
    discount_amount = format_price(discount.discount_amount)

    format_line(description, "-#{discount_amount}") + "\n"
  end

  def format_line(left, right)
    [left, right.rjust(@columns - left.size)].join
  end

  def format_price(price)
    format('%.2f', price)
  end

  def format_quantity(item)
    if ProductUnit::EACH == item.product.unit
      format('%x', item.quantity.to_i)
    else
      format('%.3f', item.quantity)
    end
  end
end
