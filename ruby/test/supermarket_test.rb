require_relative "./test_helper"

class SupermarketTest < Minitest::Test
  include SpecialOfferType

  def test_discounts
    catalog = FakeCatalog.new
    cart = ShoppingCart.new
    teller = Teller.new(catalog)

    toothbrush = Product.new("toothbrush", ProductUnit::EACH)
    catalog.add_product(toothbrush, 0.99)
    teller.add_special_offer(THREE_FOR_TWO, toothbrush, nil)
    cart.add_item_quantity(toothbrush, 5)

    apples = Product.new("apples", ProductUnit::KILO)
    catalog.add_product(apples, 1.99)
    teller.add_special_offer(PERCENT_DISCOUNT, apples, 20)
    cart.add_item_quantity(apples, 2.5)

    rice = Product.new("rice", ProductUnit::EACH)
    catalog.add_product(rice, 2.49)
    teller.add_special_offer(PERCENT_DISCOUNT, rice, 10)
    cart.add_item_quantity(rice, 2)

    toothpaste = Product.new("toothpaste", ProductUnit::EACH)
    catalog.add_product(toothpaste, 1.79)
    teller.add_special_offer(FIVE_FOR_AMOUNT, toothpaste, 7.49)
    cart.add_item_quantity(toothpaste, 6)

    cherry_tomatoes = Product.new("cherry tomatoes", ProductUnit::EACH)
    catalog.add_product(cherry_tomatoes, 0.69)
    teller.add_special_offer(TWO_FOR_AMOUNT, cherry_tomatoes, 0.99)
    cart.add_item_quantity(cherry_tomatoes, 5)

    receipt = teller.checks_out_articles_from(cart)

    output = ReceiptPrinter.new.print_receipt(receipt)

    assert_equal <<~EXPECTED_OUTPUT.strip, output
      toothbrush                          4.95
        0.99 * 5
      apples                              4.98
        1.99 * 2.500
      rice                                4.98
        2.49 * 2
      toothpaste                         10.74
        1.79 * 6
      cherry tomatoes                     3.45
        0.69 * 5
      3 for 2(toothbrush)                -0.99
      20% off(apples)                    -1.00
      10% off(rice)                      -0.50
      5 for 7.49(toothpaste)             -1.46
      2 for 0.99(cherry tomatoes)        -0.78

      Total:                             24.37
    EXPECTED_OUTPUT
  end

  def test_total_is_sum_of_line_items
    catalog = FakeCatalog.new
    cart = ShoppingCart.new
    teller = Teller.new(catalog)

    toothbrush = Product.new("toothbrush", ProductUnit::EACH)
    catalog.add_product(toothbrush, 0.33)
    teller.add_special_offer(PERCENT_DISCOUNT, toothbrush, 20)
    cart.add_item_quantity(toothbrush, 1)

    toothpaste = Product.new("toothpaste", ProductUnit::EACH)
    catalog.add_product(toothpaste, 0.33)
    teller.add_special_offer(PERCENT_DISCOUNT, toothpaste, 20)
    cart.add_item_quantity(toothpaste, 1)

    receipt = teller.checks_out_articles_from(cart)

    output = ReceiptPrinter.new.print_receipt(receipt)

    assert_equal <<~EXPECTED_OUTPUT.strip, output
      toothbrush                          0.33
      toothpaste                          0.33
      20% off(toothbrush)                -0.07
      20% off(toothpaste)                -0.07

      Total:                              0.53
    EXPECTED_OUTPUT

    # NOTE: Total should be 0.52
  end

  def test_no_floating_point_rounding_errors
    catalog = FakeCatalog.new
    cart = ShoppingCart.new
    teller = Teller.new(catalog)

    apples = Product.new("apples", ProductUnit::KILO)
    catalog.add_product(apples, 1.00)
    cart.add_item_quantity(apples, 1.005)

    receipt = teller.checks_out_articles_from(cart)

    output = ReceiptPrinter.new.print_receipt(receipt)

    assert_equal <<~EXPECTED_OUTPUT.strip, output
      apples                              1.00
        1.00 * 1.005

      Total:                              1.00
    EXPECTED_OUTPUT

    # NOTE: Total should be 1.01
  end
end
