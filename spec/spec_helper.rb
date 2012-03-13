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
  def self.su_params
    {'su' => SU_NAME, 'sp' => SU_PSWD}
  end
  def self.auth_params(org = 1)
    u = org == 1 ? TEST_ORG1[:user] : TEST_ORG2[:user]
    p = org == 2 ? TEST_ORG1[:password] : TEST_ORG2[:password]
    {'user_name' => u, 'user_password' => p}
  end
end

def waybill_skeleton(params = {})
  waybill = RS::Waybill.new
  waybill.id = params[:id]
  waybill.type = params[:type] || RS::WaybillType::TRANSPORTATION
  waybill.status = params[:status] || RS::Waybill::STATUS_SAVED
  waybill.seller_id = params[:seller_id] || 731937
  waybill.buyer_tin = params[:buyer_tin] || '12345678910'
  waybill.check_buyer_tin = params[:check_buyer_tin] ? params[:check_buyer_tin] : true
  waybill.buyer_name = params[:buyer_name] || 'სატესტო სატესტო'
  waybill.start_address = params[:start_address] || 'თბილისი'
  waybill.end_address   = params[:end_address] || 'სოხუმი'
  waybill.transport_type_id = params[:transport_type] || RS::TransportType::VEHICLE
  waybill.start_date = params[:start_date] || Time.now
  waybill.comment = params[:comment] #|| 'comment'
  if waybill.transport_type_id == RS::TransportType::VEHICLE
    waybill.car_number  = params[:car_number]  || 'WDW842'
    waybill.driver_name = params[:driver_name] || 'დიმიტრი ყურაშვილი'
    waybill.driver_tin  = params[:driver_tin]  || '02001000490'
    waybill.check_driver_tin = params[:check_driver_tin].nil? ? false : params[:check_driver_tin]
  else
    waybill.car_number = params[:car_number]
    waybill.driver_name = params[:driver_name]
    waybill.driver_tin = params[:driver_tin]
    waybill.check_driver_tin = params[:check_driver_tin]
  end
  waybill.transportation_cost = params[:transportation_cost] || 0
  waybill.transportation_cost_payer =params[:transportation_cost_payer] || RS::Waybill::TRANSPORTATION_PAID_BY_BUYER 

  if params[:items]
    items = []
    params[:items].each do |item|
      item = RS::WaybillItem.new
      item.prod_name = item[:name]
      item.unit_id = item[:unit_id]
      item.unit_name = item[:unit_name]
      item.quantity = item[:quantity]
      item.price = item[:price]
      item.bar_code = item[:code]
      items << item
    end
  else
    item = RS::WaybillItem.new
    item.prod_name = 'სატესტო საქონელი'
    item.unit_id = 99
    item.unit_name = 'ერთეული'
    item.quantity = 2
    item.price = 5
    item.bar_code = '123'
    items = [item]
  end
  waybill.items = items

  waybill
end
