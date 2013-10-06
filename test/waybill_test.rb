# -*- encoding : utf-8 -*-
require 'test_helper'

class WaybillTest < Test::Unit::TestCase
  def test_get_waybill
    waybill = RS.get_waybill(TEST_SU.merge(id: 78061328))
    refute_nil waybill
    # test header
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
    # test items
    refute_nil waybill.items
    assert_equal 1, waybill.items.size
    item = waybill.items.first
    assert_equal 416627358, item.id
    assert_equal '000000115', item.code
    assert_equal 'რულეტკა', item.name
    assert_equal 1, item.status
    assert_equal 99, item.unit_id
    assert_equal 'ცალი', item.unit_name
    assert_equal 1, item.quantity
    assert_equal 0, item.price
    assert_equal 0, item.amount
    assert_equal RS::VAT_COMMON, item.vat_type
    assert_nil item.excise_id
  end

  def test_get_waybills
    waybills = RS.get_waybills(TEST_SU.merge(number: '0083643818'))
    assert_equal 1, waybills.size
    waybill = waybills.first
    assert_equal 81915883, waybill.id
    assert_equal RS::Waybill::INNER, waybill.type
    refute_nil waybill.create_date
    assert_equal '206322102', waybill.buyer_tin
    assert_equal 'სატესტო კოდი', waybill.buyer_name
    assert_equal 'ქ. აბაშა, კაჭარავას 35', waybill.start_address
    assert_equal 'ქ. აბაშა, კაჭარავას 35', waybill.end_address
    refute_nil waybill.activation_date
    assert_equal RS::Waybill::ACTIVE, waybill.status
    assert_equal 24000, waybill.amount
    assert_equal 'vin222', waybill.vehicle
    assert_equal '0083643818', waybill.number
    refute_nil waybill.begin_date
    refute waybill.confirmed
    assert waybill.canceled
    assert_equal false, waybill.corrected
  end

  def test_get_buyer_waybills
    waybills = RS.get_buyer_waybills(TEST_SU.merge(number: '0083644572'))
    assert_equal 1, waybills.size
    waybill = waybills.first
    assert_equal 81916664, waybill.id
    assert_equal RS::Waybill::TRANS, waybill.type
    refute_nil waybill.create_date
    assert_equal '206322102', waybill.buyer_tin
    assert_equal 'სატესტო კოდი', waybill.buyer_name
    assert_equal '12345678910', waybill.seller_tin
    assert_equal 'sofio სატესტო', waybill.seller_name
    assert_equal 'სატესტო 2 მის', waybill.start_address
    assert_equal 'ბათუმი', waybill.end_address
    assert_equal '41001022577', waybill.driver_tin
    assert_equal 'ხვიჩა ერაძე', waybill.driver_name
    refute_nil waybill.activation_date
    refute_nil waybill.begin_date
    refute_nil waybill.delivery_date
    assert_equal RS::Waybill::CLOSED, waybill.status
    assert_equal 15, waybill.amount
    assert_equal 'fff567', waybill.vehicle
    assert_equal '0083644572', waybill.number
    refute waybill.confirmed
    refute waybill.canceled
    refute waybill.corrected
  end
end
