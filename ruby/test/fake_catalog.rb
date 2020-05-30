class FakeCatalog < SupermarketCatalog
  def initialize
    @products = {}
  end

  def add_product(product)
    @products[product.name] = product
  end
end
