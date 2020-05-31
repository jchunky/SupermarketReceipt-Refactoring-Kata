Product = Struct.new(:name, :unit, :unit_price) do
  def initialize(name, unit, unit_price)
    super(name, unit, unit_price.to_d)
  end
end
