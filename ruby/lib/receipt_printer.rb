class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    result = ''
    result << receipt.items.map(&method(:format_receipt_item)).join
    result << receipt.discounts.map(&method(:format_discount)).join
    result << "\n"
    result << 'Total:'.ljust(@columns - 10)
    result << cash(receipt.total_price).rjust(10)
    result
  end

  private

  def format_receipt_item(item)
    result = ''
    price = cash(item.total_price)
    quantity = present_quantity(item)
    name = item.product.name
    unit_price = cash(item.price)

    result << name.ljust(@columns - 10)
    result << price.rjust(10)
    result << "\n"
    result << "  #{unit_price} * #{quantity}\n" if item.quantity != 1
    result
  end

  def format_discount(discount)
    result = ''
    product_presentation = discount.product.name
    price_presentation = cash(discount.discount_amount)
    description = discount.description

    result << "#{description}(#{product_presentation})".ljust(@columns - 10)
    result << "-#{price_presentation}".rjust(10)
    result << "\n"
    result
  end

  def present_quantity(item)
    if ProductUnit::EACH == item.product.unit
      format('%x', item.quantity.to_i)
    else
      format('%.3f', item.quantity)
    end
  end

  def cash(price)
    format('%.2f', price)
  end
end
