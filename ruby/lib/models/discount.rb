Discount = Struct.new(:product, :description, :discount_amount) do
  def initialize(product, description, discount_amount)
    super(product, description, discount_amount.round(2))
  end
end
