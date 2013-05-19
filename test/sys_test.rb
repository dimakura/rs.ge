# -*- encoding : utf-8 -*-
require 'test_helper'

class GeneralTest < Test::Unit::TestCase
  def test_what_is_my_ip
    ip = RS.what_is_my_ip
    assert ip
    assert ip.is_a?(String)
    assert ip =~ /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/
  end

  def test_create_user
    su = "invoice_ge_#{rand(1000)}"
    sp = '123456'
    assert RS.create_user(TEST_USER.merge(ip: RS.what_is_my_ip, name: 'invoice.ge test user', su: su, sp: sp)) == true
    check_result = RS.check_user(su: su, sp: sp)
    assert_equal 731937, check_result[:payer]
    user_id = check_result[:user]
    assert user_id > 0
    assert_nil RS.check_user(su: su, sp: 'wrongpassword')
    assert RS.update_user(TEST_USER.merge(ip: RS.what_is_my_ip, name: 'invoice.ge test user', su: su, sp: 'newpassword')) == true
    assert_equal user_id, RS.check_user(su: su, sp: 'newpassword')[:user]
  end
end
