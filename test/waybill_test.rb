# -*- encoding : utf-8 -*-
require 'test_helper'

class WaybillTest < Test::Unit::TestCase
  def test_get_waybill
    waybill = RS.get_waybill(TEST_SU.merge(id: 78061328))
    refute_nil waybill
    assert_equal 78061328, waybill.id
    assert_nil waybill.parent_id
    assert_equal '0080163857', waybill.number
    assert_equal RS::Waybill::INNER, waybill.type
    assert_equal RS::Waybill::DEACTIVATED, waybill.status
    assert_equal 731937, waybill.seller_id
    assert_equal '206322102', waybill.seller_tin
    assert_equal 'სატესტო კოდი', waybill.seller_name
    assert_equal '206322102', waybill.buyer_tin
    assert_equal false, waybill.check_buyer_tin, 'XXX: misterious false'
    assert_nil waybill.buyer_name, 'XXX: misterious nil'
    assert_equal '35001028457', waybill.driver_tin
    assert_equal true, waybill.check_driver_tin
    assert_equal 'იურა აბრამოვი', waybill.driver_name
    assert_equal 'ასდდფფ გფგჰფ  გფგ', waybill.start_address
    assert_equal 'აღმაშენებლის 8', waybill.end_address
    refute_nil waybill.create_date
    refute_nil waybill.activation_date
    refute_nil waybill.begin_date
    assert_nil waybill.delivery_date
    refute_nil waybill.close_date
    assert_equal 10, waybill.transport_cost
    assert_equal RS::Waybill::TRANSP_PAID_BY_BUYER, waybill.transport_cost_payer
    assert_equal 'IJL652', waybill.vehicle
    assert_equal RS::Waybill::TRANS_VEHICLE, waybill.transport_type
    assert_nil waybill.transport_name
    assert_nil waybill.comment
    assert_equal 'ზეინკალი, აბრამიძე ტარიელი', waybill.seller_info
    assert_equal 'ელ.შემდუღებელი, აბუაშვილი შოთა', waybill.buyer_info
    assert_equal 0, waybill.amount
    assert_equal 103459, waybill.su_id
    assert_equal true, waybill.confirmed
    refute_nil waybill.confirmation_date
    assert_nil waybill.invoice_id
    # assert_equal 2, waybill.items.size

    # attr_accessor :confirmed, :confirmation_date
    # attr_accessor :invoice_id
  end
end
