class Receipt
  attr_reader :items, :discounts

  def initialize
    @items = []
    @discounts = []
  end

  def total_price
    @items.sum(&:total_price) - @discounts.sum(&:discount_amount)
  end

  def add_product(receipt_item)
    @items << receipt_item
  end

  def add_discount(discount)
    @discounts << discount
  end
end
