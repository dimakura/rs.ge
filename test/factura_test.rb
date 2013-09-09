# -*- encoding : utf-8 -*-
require 'test_helper'

class FacturaTest < Test::Unit::TestCase
  def test_create_factura
    seller_id = TEST_PAYER_ID
    factura = RS::Factura.new(date: Time.now, seller_id: seller_id)
    resp = RS.save_factura(factura, TEST_SU.merge(buyer_tin: '12345678910'))
    puts resp
  end
end
