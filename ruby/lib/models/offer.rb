Offer = Struct.new(:offer_type, :product, :argument) do
  def initialize(offer_type, product, argument)
    super(offer_type, product, argument.to_d)
  end
end
