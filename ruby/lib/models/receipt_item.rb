ReceiptItem = Struct.new(:product, :quantity, :unit_price) do
  def total_price
    quantity * unit_price
  end
end
