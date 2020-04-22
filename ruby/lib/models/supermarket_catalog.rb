class SupermarketCatalog
  def initialize
    @prices = {}
  end

  def add_product(product, price)
    @prices[product.name] = price
  end

  def unit_price(p)
    @prices.fetch(p.name)
  end
end
