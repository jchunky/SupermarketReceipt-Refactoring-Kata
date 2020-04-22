require_relative './test_helper'

class SupermarketTest < Minitest::Test
  def setup
    @cart = ShoppingCart.new
    @catalog = SupermarketCatalog.new
    @teller = Teller.new(@catalog)

    @toothbrush = Product.new('toothbrush', ProductUnit::EACH)
    @catalog.add_product(@toothbrush, 0.99)

    @apples = Product.new('apples', ProductUnit::KILO)
    @catalog.add_product(@apples, 1.99)
  end

  def test_no_discounts
    @cart.add_item_quantity(@apples, 2.5)

    receipt = @teller.checks_out_articles_from(@cart)

    assert_in_delta 4.975, receipt.total_price, 0.01

    assert_equal <<~TEXT.strip, ReceiptPrinter.new.print_receipt(receipt)
      apples                              4.98
        1.99 * 2.500

      Total:                              4.98
    TEXT
  end

  def test_ten_percent_discount
    @teller.add_special_offer(
      SpecialOfferType::TEN_PERCENT_DISCOUNT,
      @toothbrush,
      10.0
    )

    @cart.add_item_quantity(@toothbrush, 1)

    receipt = @teller.checks_out_articles_from(@cart)

    assert_in_delta 0.891, receipt.total_price, 0.01

    assert_equal <<~TEXT.strip, ReceiptPrinter.new.print_receipt(receipt)
      toothbrush                          0.99
      10.0% off(toothbrush)              -0.10

      Total:                              0.89
    TEXT
  end
end
