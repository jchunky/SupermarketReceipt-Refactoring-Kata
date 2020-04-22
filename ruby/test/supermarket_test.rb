require_relative './test_helper'

class SupermarketTest < Minitest::Test
  def test_no_discounts
    catalog = SupermarketCatalog.new
    toothbrush = Product.new('toothbrush', ProductUnit::EACH)
    catalog.add_product(toothbrush, 0.99)

    apples = Product.new('apples', ProductUnit::KILO)
    catalog.add_product(apples, 1.99)

    cart = ShoppingCart.new
    cart.add_item_quantity(apples, 2.5)

    teller = Teller.new(catalog)
    teller.add_special_offer(
      SpecialOfferType::TEN_PERCENT_DISCOUNT,
      toothbrush,
      10.0
    )

    receipt = teller.checks_out_articles_from(cart)

    assert_in_delta 4.975, receipt.total_price, 0.01

    expected_receipt = <<~TEXT.strip
      apples                              4.98
        1.99 * 2.500

      Total:                              4.98
    TEXT

    assert_equal expected_receipt, ReceiptPrinter.new.print_receipt(receipt)
  end

  def test_ten_percent_discount
    catalog = SupermarketCatalog.new
    toothbrush = Product.new('toothbrush', ProductUnit::EACH)
    catalog.add_product(toothbrush, 0.99)

    apples = Product.new('apples', ProductUnit::KILO)
    catalog.add_product(apples, 1.99)

    cart = ShoppingCart.new
    cart.add_item_quantity(toothbrush, 1)

    teller = Teller.new(catalog)
    teller.add_special_offer(
      SpecialOfferType::TEN_PERCENT_DISCOUNT,
      toothbrush,
      10.0
    )

    receipt = teller.checks_out_articles_from(cart)

    assert_in_delta 0.891, receipt.total_price, 0.01

    expected_receipt = <<~TEXT.strip
      toothbrush                          0.99
      10.0% off(toothbrush)              -0.10

      Total:                              0.89
    TEXT

    assert_equal expected_receipt, ReceiptPrinter.new.print_receipt(receipt)
  end
end
