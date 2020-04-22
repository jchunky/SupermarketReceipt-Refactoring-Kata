class ReceiptPrinter
  def initialize(columns = 40)
    @columns = columns
  end

  def print_receipt(receipt)
    result = ''
    receipt.items.each do |item|
      result << format_receipt_item(item)
    end
    receipt.discounts.each do |discount|
      result << format_discount(discount)
    end
    result << "\n"
    result << format('Total: %33.2f', receipt.total_price)
    result
  end

  private

  def format_receipt_item(item)
    result = ''
    price = cash(item.total_price)
    quantity = present_quantity(item)
    name = item.product.name
    unit_price = cash(item.price)

    result << name.ljust(30) + price.rjust(10) + "\n"
    result << "  #{unit_price} * #{quantity}\n" if item.quantity != 1
    result
  end

  def format_discount(discount)
    result = ''
    product_presentation = discount.product.name
    price_presentation = cash(discount.discount_amount)
    description = discount.description

    result << "#{description}(#{product_presentation})".ljust(30)
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
