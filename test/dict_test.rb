# -*- encoding : utf-8 -*-
require 'test_helper'

class DictionaryTest < Test::Unit::TestCase
  def test_get_name_from_tin
    name = RS.get_name_from_tin(TEST_SU.merge(tin: '422430239'))
    assert_equal 'შპს ც12', name
  end
end
