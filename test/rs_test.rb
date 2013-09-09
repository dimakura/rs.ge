# -*- encoding : utf-8 -*-
require 'test_helper'

class GeneralTest < Test::Unit::TestCase
  def test_tin_correctness
    refute RS.valid_tin?('01234'),        '05 digits tin'
    assert RS.valid_tin?('012345'),       '06 digits tin (diplomats!)'
    refute RS.valid_tin?('0123456'),      '07 digits tin (diplomats!)'
    refute RS.valid_tin?('01234567'),     '08 digits tin'  
    refute RS.valid_tin?('01234567'),     '08 digits tin'
    assert RS.valid_tin?('012345678'),    '09 digits tin'
    refute RS.valid_tin?('0123456789'),   '10 digits tin'
    assert RS.valid_tin?('01234567891'),  '11 digits tin'
    refute RS.valid_tin?('012345678912'), '12 digits tin'
  end
end
