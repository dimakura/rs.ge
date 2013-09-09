# -*- encoding : utf-8 -*-
require 'test_helper'

class SystemTest < Test::Unit::TestCase
  def test_what_is_my_ip
    ip = RS.what_is_my_ip
    assert ip
    assert ip.is_a?(String)
    assert ip =~ /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/
  end

  def test_check_user
    data = RS.check_user(TEST_SU)
    assert_equal 731937, data[:payer]
    assert_equal 20155, data[:user]
  end
end
