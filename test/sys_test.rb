# -*- encoding : utf-8 -*-
require 'test_helper'

class GeneralTest < Test::Unit::TestCase
  include RS

  def test_what_is_my_ip
    ip = what_is_my_ip
    assert ip
    assert ip.is_a?(String)
    assert ip =~ /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/
  end
end
