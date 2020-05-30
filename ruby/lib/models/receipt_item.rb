ReceiptItem = Struct.new(:product, :quantity) do
  def total_price
    quantity * unit_price
  end

  def unit_price
    product.unit_price
  end
end
