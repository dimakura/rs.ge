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

RS.config.su = 'dimtiri1979'
RS.config.sp = '123456'
