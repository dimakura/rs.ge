# -*- encoding : utf-8 -*-

# Savon (SOAP client)

require 'savon'

HTTPI.log = false
Savon.configure do |config|
  config.log = false
end

# RSpec

require 'rspec'

RSpec.configure do |config|
  config.include(RSpec::Matchers)
end

# Test options.

require 'rs'
require 'helpers'

TEST_USERNAME = 'tbilisi'
TEST_PASSWORD = '123456'
RS.config.su = RS::BaseRequest::DEFAULTS[:su]
RS.config.sp = RS::BaseRequest::DEFAULTS[:sp]
RS.config.user_id = RS::BaseRequest::DEFAULTS[:user_id]
DEFAULT_PAYER  = RS::BaseRequest::DEFAULTS[:payer_id]

# ეს განახლება საჭიროა, რათა სატესტო მომხმარებელი მუშაობდეს იგივე IP მისამართიდან, საიდანაც ეშვება ეს ტესტები.
# IP მისამართით შეზღუდვა მნიშვნელვანია ანგარიშ-ფაქტურის სერვისებისთვის!
RS.sys.update_user(username: TEST_USERNAME, password: TEST_PASSWORD, ip: RS.sys.what_is_my_ip, name: 'invoice.ge', su: RS.config.su, sp: RS.config.sp)
