# -*- encoding : utf-8 -*-
require 'test_helper'

class SystemTests < Test::Unit::TestCase
  def test_what_is_my_ip
    ip = RS.what_is_my_ip
    assert ip
    assert ip.is_a?(String)
    assert ip =~ /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/
  end

  def test_check_user
    data = RS.check_user(TEST_SU)
    assert_equal 783, data[:user_id]
    assert_equal 20155, data[:s_user_id]
  end

  def test_get_users
    users = RS.get_users(TEST_USER)
    assert_equal 165, users.size
    user = users[0]
    assert_equal 21111, user.id
    assert_equal 'TBILISI', user.username
    assert_equal '31.146.178.142', user.ip
    refute_nil user.name
    assert_equal 731937, user.payer_id
    # {:id=>"21111", :user_name=>"TBILISI", :un_id=>"731937", :ip=>"31.146.178.142", :name=>"parolia: 123456"}
  end
end
