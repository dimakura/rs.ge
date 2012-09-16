# -*- encoding : utf-8 -*-

# Savon (SOAP client)

require 'savon'

HTTPI.log = false
Savon.configure do |config|
  config.log = false
end

# RSpec

require 'rs'
require 'rspec'

RSpec.configure do |config|
  config.include(RSpec::Matchers)
end

# Test options.

require 'helpers'

RS.config.su  = RS::BaseRequest::DEFAULTS[:su]
RS.config.sp  = RS::BaseRequest::DEFAULTS[:sp]
DEFAULT_PAYER = RS::BaseRequest::DEFAULTS[:payer_id]
DEFAULT_USER  = RS::BaseRequest::DEFAULTS[:user_id]
