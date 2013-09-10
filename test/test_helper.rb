# -*- encoding : utf-8 -*-
require 'test/unit'
require 'active_support/core_ext/object/blank'
require 'savon'
require 'rs'

TEST_PAYER_ID = 731937
TEST_ORG_TIN = '206322102'
TEST_USER = { username: 'tbilisi', password: '123456' }
TEST_USER_ID = 783
TEST_SU = { su: 'dimitri1979', sp: '123456' }

# RS.update_user(username: 'tbilisi', password: '123456', ip: RS.what_is_my_ip, su: 'dimitri1979', sp: '123456', name: 'invoice.ge')
