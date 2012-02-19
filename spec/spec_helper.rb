# -*- encoding : utf-8 -*-

# Savon (SOAP client)

require 'savon'

HTTPI.log = false
Savon.log = false

# SimpleCov

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

# RSpec

require 'rspec'
require 'rs'

RSpec.configure do |config|
  config.include(RSpec::Matchers)
end

# RS namespace is included by default

include RS

# Test organizations provided by RS.GE service

module RS
  unless defined?(TEST_ORG1) and defined?(TEST_ORG2)
    TEST_ORG1 = { :user => 'tbilisi',  :password => '123456', :taxid => '206322102'}
    TEST_ORG2 = { :user => 'satesto2', :password => '123456', :taxid => '12345678910'}
  end
  unless defined?(SU_NAME) and defined?(SU_PSWD)
    SU_NAME = 'dimitri1979'
    SU_PSWD = '123456'
  end
  def su_params
    {'su' => SU_NAME, 'sp' => SU_PSWD}
  end
  def auth_params(org = 1)
    u = org == 1 ? TEST_ORG1[:user] : TEST_ORG2[:user]
    p = org == 2 ? TEST_ORG1[:password] : TEST_ORG2[:password]
    {'user_name' => u, 'user_password' => p}
  end
end
