# -*- encoding : utf-8 -*-
require 'test_helper'

class FacturaTest < Test::Unit::TestCase
  def test_create_factura
    factura = RS::Factura.new(date: Time.now, seller_id: TEST_PAYER_ID)
    assert_nil factura.id
    RS.save_factura(factura, TEST_SU.merge(buyer_tin: '12345678910', user_id: TEST_USER_ID))
    refute_nil factura.id
    assert factura.id > 0
  end
end
