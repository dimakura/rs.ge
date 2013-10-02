# -*- encoding : utf-8 -*-
require 'test_helper'

class WaybillTest < Test::Unit::TestCase
  def test_get_waybill
    waybill = RS.get_waybill(TEST_SU.merge(id: 78061328))
    refute_nil waybill
    assert_equal 78061328, waybill.id
    assert_equal '0080163857', waybill.number
    assert_equal RS::Waybill::INNER, waybill.type
    assert_nil waybill.parent_id
    
  end
end
