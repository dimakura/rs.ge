# -*- encoding : utf-8 -*-
require 'test_helper'

class DictionaryTest < Test::Unit::TestCase
  def test_get_oranizaton_info_from_tin
    info = RS.get_oranizaton_info_from_tin(TEST_SU.merge(user_id: TEST_USER_ID, tin: '204417363'))
    assert 1, info[:id]
    assert_equal 'შპს ც12', info[:name]
  end

  def test_get_name_from_tin
    name = RS.get_name_from_tin(TEST_SU.merge(tin: '422430239'))
    assert_equal 'შპს ც12', name
  end

  # def is_vat_payer => get vat payer info from TIN
end
