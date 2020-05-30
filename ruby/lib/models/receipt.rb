Receipt = Struct.new(:items, :discounts) do
  def total_price
    items.sum(&:total_price) - discounts.sum(&:discount_amount)
  end
end
