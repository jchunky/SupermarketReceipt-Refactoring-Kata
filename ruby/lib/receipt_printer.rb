class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    result = ""
    receipt.items.each do |item|
      price = format_price(item.total_price)
      quantity = format_quantity(item)
      name = item.product.name
      unit_price = format_price(item.price)

      whitespace_size = @columns - name.size - price.size
      line = name + whitespace(whitespace_size) + price + "\n"

      line += "  " + unit_price + " * " + quantity + "\n" if item.quantity != 1

      result.concat(line)
    end
    receipt.discounts.each do |discount|
      product_presentation = discount.product.name
      price_presentation = format_price(discount.discount_amount)
      description = discount.description
      result.concat(description)
      result.concat("(")
      result.concat(product_presentation)
      result.concat(")")
      result.concat(whitespace(@columns - 3 - product_presentation.size - description.size - price_presentation.size))
      result.concat("-")
      result.concat(price_presentation)
      result.concat("\n")
    end
    result.concat("\n")
    price_presentation = format_price(receipt.total_price)
    total = "Total: "
    whitespace = whitespace(@columns - total.size - price_presentation.size)
    result.concat(total, whitespace, price_presentation)
    result
  end

  private

  def format_price(price)
    "%.2f" % price
  end

  def format_quantity(item)
    if ProductUnit::EACH == item.product.unit
      "%x" % item.quantity
    else
      "%.3f" % item.quantity
    end
  end

  def whitespace(size)
    " " * size
  end
end
