# -*- encoding : utf-8 -*-
require 'test_helper'

class DictionaryTest < Test::Unit::TestCase
  def test_get_oranizaton_info_from_tin
    info = RS.get_oranizaton_info_from_tin(TEST_SU.merge(user_id: TEST_USER_ID, tin: '204417363'))
    assert_equal 246229, info[:id]
    assert_equal 'შპს  ღვინის სამყარო - მამული XXI', info[:name]
  end

  def test_get_oranizaton_info_from_tin2
    info = RS.get_oranizaton_info_from_tin(TEST_SU.merge(user_id: TEST_USER_ID, tin: '123015'))
    assert_equal -122, info[:id]
    assert_equal 'ვალტერ ვანგბერგი', info[:name]
  end

  def test_is_vat_payer
    assert_equal true, RS.is_vat_payer(TEST_SU.merge(payer_id: 246229))
  end

  def test_get_name_from_tin
    name = RS.get_name_from_tin(TEST_SU.merge(tin: '422430239'))
    assert_equal 'შპს ც12', name
  end

  def test_get_units
    units = RS.get_units(TEST_SU)
    assert units.is_a?(Hash)
    refute units.empty?
    assert_equal 14, units.size
  end

  def test_get_excise_codes
    codes = RS.get_excise_codes(TEST_SU)
    assert_equal 278, codes.size
    code0 = codes.first
    refute_nil code0
    assert_equal 224, code0.id
    assert_equal 'ეთილის სპირტი', code0.name
    assert_equal '2207', code0.code
    assert_equal 2.6, code0.price
  end
end
