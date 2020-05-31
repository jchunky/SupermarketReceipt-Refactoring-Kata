require_relative "./test_helper"

class SupermarketTest < Minitest::Test
  def test_discounts
    teller = Teller.new

    toothbrush = Product.new("toothbrush", :each, 0.99)
    teller.add_special_offer(:three_for_two, toothbrush, nil)
    teller.add_item_quantity(toothbrush, 5)

    apples = Product.new("apples", :kilo, 1.99)
    teller.add_special_offer(:percent_discount, apples, 20)
    teller.add_item_quantity(apples, 2.5)

    rice = Product.new("rice", :each, 2.49)
    teller.add_special_offer(:percent_discount, rice, 10)
    teller.add_item_quantity(rice, 2)

    toothpaste = Product.new("toothpaste", :each, 1.79)
    teller.add_special_offer(:five_for_amount, toothpaste, 7.49)
    teller.add_item_quantity(toothpaste, 6)

    cherry_tomatoes = Product.new("cherry tomatoes", :each, 0.69)
    teller.add_special_offer(:two_for_amount, cherry_tomatoes, 0.99)
    teller.add_item_quantity(cherry_tomatoes, 5)

    bread = Product.new("bread", :each, 1.79)
    teller.add_item_quantity(bread, 6)

    output = ReceiptPrinter.new.print_receipt(teller.receipt)

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
      bread                              10.74
        1.79 * 6
      3 for 2(toothbrush)                -0.99
      20% off(apples)                    -1.00
      10% off(rice)                      -0.50
      5 for 7.49(toothpaste)             -1.46
      2 for 0.99(cherry tomatoes)        -0.78

      Total:                             35.11
    EXPECTED_OUTPUT
  end

  def test_fractional_discounts
    teller = Teller.new

    toothbrush = Product.new("toothbrush", :each, 0.33)
    teller.add_special_offer(:percent_discount, toothbrush, 20)
    teller.add_item_quantity(toothbrush, 1)

    toothpaste = Product.new("toothpaste", :each, 0.33)
    teller.add_special_offer(:percent_discount, toothpaste, 20)
    teller.add_item_quantity(toothpaste, 1)

    output = ReceiptPrinter.new.print_receipt(teller.receipt)

    assert_equal <<~EXPECTED_OUTPUT.strip, output
      toothbrush                          0.33
      toothpaste                          0.33
      20% off(toothbrush)                -0.07
      20% off(toothpaste)                -0.07

      Total:                              0.52
    EXPECTED_OUTPUT
  end
end
