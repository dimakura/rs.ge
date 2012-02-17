# encoding: utf-8

# Savon (SOAP client)

require 'savon'
require 'httpi'

HTTPI.log = false
Savon.configure do |config|
  config.log = false
end

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
end