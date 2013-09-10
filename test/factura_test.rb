# -*- encoding : utf-8 -*-
require 'test_helper'

class FacturaTest < Test::Unit::TestCase
  def test_factura_items
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
    # get factura items
    items = RS.get_factura_items(TEST_SU.merge(user_id: TEST_USER_ID, id: factura.id))
    assert_equal 1, items.size
    # delete factura item
    assert RS.delete_factura_item(TEST_SU.merge(user_id: TEST_USER_ID, id: items.first.id, factura_id: factura.id))
    items2 = RS.get_factura_items(TEST_SU.merge(user_id: TEST_USER_ID, id: factura.id))
    assert items2.empty?
  end

  def test_factura_cycle
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
    # get factura items
    items = RS.get_factura_items(TEST_SU.merge(user_id: TEST_USER_ID, id: factura.id))
    assert_equal 1, items.size
    # send factura
    assert RS.send_factura(TEST_SU.merge(user_id: TEST_USER_ID, id: factura.id, status: RS::Factura::NEW))
    factura = RS.get_factura_by_id(TEST_SU.merge(user_id: TEST_USER_ID, id: factura.id))
    assert_equal RS::Factura::SENT, factura.status
  end

  def test_get_factura_and_items
    id = 33483243
    # getting factura
    factura = RS.get_factura_by_id(TEST_SU.merge(user_id: TEST_USER_ID, id: id))
    assert_equal id, factura.id
    refute_nil factura.date
    refute_nil factura.register_date
    assert factura.date.is_a?(Date)
    assert factura.register_date.is_a?(Date)
    assert_equal RS::Factura::NEW, factura.status
    assert_equal 731937, factura.seller_id
    assert_equal 1149251, factura.buyer_id
    assert_equal 'ეა-70', factura.seria
    assert_nil factura.number
    assert_nil factura.corrected_id
    assert_nil factura.correction_type
    assert factura.new?
    refute factura.sent?
    refute factura.confirmed?
    refute factura.canceled?
    refute factura.corrected?
    # getting factura items
    items = RS.get_factura_items(TEST_SU.merge(user_id: TEST_USER_ID, id: id))
    assert_equal 1, items.size
    item = items.first
    assert_equal 226635210, item.id
    assert_equal 'potato', item.good
    assert_equal 'kg', item.unit
    assert_equal 100, item.amount
    assert_equal 10, item.quantity
    assert_equal 15.25, item.vat
    assert_equal 0, item.excise_amount
    assert_nil item.excise_code
  end
end
