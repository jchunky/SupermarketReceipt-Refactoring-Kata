ReceiptItem = Struct.new(:product, :quantity) do
  def initialize(product, quantity)
    super(product, quantity.to_d)
  end

  def total_price
    (quantity * unit_price).round(2)
  end

  def unit_price
    product.unit_price
  end
end
