require_relative './test_helper'

class SupermarketTest < Minitest::Test
  include SpecialOfferType

  def test_ten_percent_discount
    catalog = SupermarketCatalog.new
    teller = Teller.new(catalog)
    cart = ShoppingCart.new
    receipt_printer = ReceiptPrinter.new

    toothbrush = Product.new('toothbrush', ProductUnit::EACH)
    catalog.add_product(toothbrush, 0.99)
    teller.add_special_offer(THREE_FOR_TWO, toothbrush, nil)
    cart.add_item_quantity(toothbrush, 4)

    apples = Product.new('apples', ProductUnit::KILO)
    catalog.add_product(apples, 1.99)
    teller.add_special_offer(TEN_PERCENT_DISCOUNT, apples, 20.0)
    cart.add_item_quantity(apples, 2.5)

    rice = Product.new('rice', ProductUnit::EACH)
    catalog.add_product(rice, 2.49)
    teller.add_special_offer(TEN_PERCENT_DISCOUNT, rice, 10.0)
    cart.add_item_quantity(rice, 2)

    tooth_paste = Product.new('tooth paste', ProductUnit::EACH)
    catalog.add_product(tooth_paste, 1.79)
    teller.add_special_offer(FIVE_FOR_AMOUNT, tooth_paste, 7.49)
    cart.add_item_quantity(tooth_paste, 6)

    bread = Product.new('bread', ProductUnit::EACH)
    catalog.add_product(bread, 0.99)
    teller.add_special_offer(TWO_FOR_AMOUNT, bread, 1.50)
    cart.add_item_quantity(bread, 5)

    cherry_tomatoes = Product.new('cherry tomatoes', ProductUnit::EACH)
    catalog.add_product(cherry_tomatoes, 0.69)
    cart.add_item_quantity(cherry_tomatoes, 2)

    receipt = teller.checks_out_articles_from(cart)

    assert_equal <<~RECEIPT.strip, receipt_printer.print_receipt(receipt)
      toothbrush                          3.96
        0.99 * 4
      apples                              4.98
        1.99 * 2.500
      rice                                4.98
        2.49 * 2
      tooth paste                        10.74
        1.79 * 6
      bread                               4.95
        0.99 * 5
      cherry tomatoes                     1.38
        0.69 * 2
      3 for 2(toothbrush)                -0.99
      20.0% off(apples)                  -1.00
      10.0% off(rice)                    -0.50
      5 for 7.49(tooth paste)            -1.46
      2 for 1.5(bread)                   -0.96

      Total:                             26.08
    RECEIPT
  end
end
