# -*- encoding : utf-8 -*-
require 'test_helper'

class FacturaTest < Test::Unit::TestCase
  def test_create_factura
    factura = RS::Factura.new(date: Time.now, seller_id: TEST_PAYER_ID)
    factura_item = RS::FacturaItem.new(factura: factura, good: 'potato', unit: 'kg', quantity: 10, amount: 100, vat: 18)
    assert_nil factura.id
    assert_nil factura_item.id
    # save factura
    assert RS.save_factura(factura, TEST_SU.merge(buyer_tin: '12345678910', user_id: TEST_USER_ID))
    refute_nil factura.id
    assert factura.id > 0
    # save factura item
    assert RS.save_factura_item(factura_item, TEST_SU.merge(user_id: TEST_USER_ID))
    refute_nil factura_item.id
    assert factura_item.id > 0
  end

  def test_get_factura
    id = 33483243
    factura = RS.get_factura_by_id(TEST_SU.merge(user_id: TEST_USER_ID, id: id))
    assert_equal id, factura.id
    refute_nil factura.date
    refute_nil factura.register_date
    assert factura.date.is_a?(Date)
    assert factura.register_date.is_a?(Date)
    assert_equal RS::Factura::NOT_SENT, factura.status
    assert_equal 731937, factura.seller_id
    assert_equal 1149251, factura.buyer_id
    assert_equal 'ეა-70', factura.seria
    assert_nil factura.number
    assert_nil factura.corrected_id
  end
end
