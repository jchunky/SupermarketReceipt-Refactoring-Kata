require_relative "./test_helper"

class SupermarketTest < Minitest::Test
  include SpecialOfferType

  def test_ten_percent_discount
    catalog = FakeCatalog.new
    cart = ShoppingCart.new
    teller = Teller.new(catalog)

    toothbrush = Product.new("toothbrush", ProductUnit::EACH)
    catalog.add_product(toothbrush, 0.99)
    teller.add_special_offer(X_FOR_Y, toothbrush, x: 3, y: 2)
    cart.add_item_quantity(toothbrush, 4)

    apples = Product.new("apples", ProductUnit::KILO)
    catalog.add_product(apples, 1.99)
    teller.add_special_offer(PERCENT_DISCOUNT, apples, percent: 20)
    cart.add_item_quantity(apples, 2.5)

    rice = Product.new("rice", ProductUnit::EACH)
    catalog.add_product(rice, 2.49)
    teller.add_special_offer(PERCENT_DISCOUNT, rice, percent: 10)
    cart.add_item_quantity(rice, 3)

    toothpaste = Product.new("toothpaste", ProductUnit::EACH)
    catalog.add_product(toothpaste, 1.79)
    teller.add_special_offer(X_FOR_AMOUNT, toothpaste, x: 5, amount: 8)
    cart.add_item_quantity(toothpaste, 6)

    cherry_tomatoes = Product.new("cherry tomatoes", ProductUnit::EACH)
    catalog.add_product(cherry_tomatoes, 0.69)
    teller.add_special_offer(X_FOR_AMOUNT, cherry_tomatoes, x: 2, amount: 0.99)
    cart.add_item_quantity(cherry_tomatoes, 6)

    receipt = teller.checks_out_articles_from(cart)

    assert_equal <<~RECEIPT.strip, ReceiptPrinter.new.print_receipt(receipt)
      toothbrush                          3.96
        0.99 * 4
      apples                              4.98
        1.99 * 2.500
      rice                                7.47
        2.49 * 3
      toothpaste                         10.74
        1.79 * 6
      cherry tomatoes                     4.14
        0.69 * 6
      3 for 2(toothbrush)                -0.99
      20% off(apples)                    -1.00
      10% off(rice)                      -0.75
      5 for 8(toothpaste)                -0.95
      2 for 0.99(cherry tomatoes)        -1.17

      Total:                             26.43
    RECEIPT
  end
end
