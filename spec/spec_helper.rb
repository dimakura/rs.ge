# -*- encoding : utf-8 -*-

# Savon (SOAP client)

require 'savon'

HTTPI.log = false
Savon.log = false

# RSpec

require 'rs'
require 'rspec'

RSpec.configure do |config|
  config.include(RSpec::Matchers)
end

# Test options.

USER01 = {username: 'tbilisi', password: '123456'}

RS.config.su = 'dimtiri1979'
RS.config.sp = '123456'
