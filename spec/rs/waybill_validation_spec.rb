# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'rs'

def validable_test(cntxt, validable, field, has_errors)
  describe cntxt do
    before(:all) do
      yield(validable) if block_given?
      validable.validate
    end
    subject { validable.validation_errors[field] }
    if has_errors
      it("Errors for #{field} not nil")   { should_not be_nil }
      it("Errors for #{field} not empty") { should_not be_empty }
    else
      it("Errors for #{field} are nil")   { should be_nil }
    end
  end
end

describe 'waybill validation' do
  before(:all) do
    @waybill = RS::Waybill.new
    @waybill.validate
  end
  subject { @waybill }
  it { should_not be_valid }
  specify do
    # buyer TIN
    validable_test('buyer tin errors', @waybill, :buyer_tin, true)
    validable_test('fix buyer tin errors incorrectly', @waybill, :buyer_tin, true) do |waybill|
      waybill.buyer_tin = '123'
      waybill.check_buyer_tin = true
    end
    validable_test('fix buyer tin errors correctly', @waybill, :buyer_tin, false) do |waybill|
      waybill.buyer_tin = '123456789'
      waybill.check_buyer_tin = true
    end
    # buyer name
    validable_test('buyer name error', @waybill, :buyer_name, true) do |waybill|
      waybill.check_buyer_tin = false
    end
    validable_test('fix buyer name error', @waybill, :buyer_name, false) do |waybill|
      waybill.buyer_name = 'dimitri'
    end
    # car number
    validable_test('car number error', @waybill, :car_number, true) do |waybill|
      waybill.transport_type_id = RS::TransportType::VEHICLE
    end
    validable_test('fix car number error', @waybill, :car_number, false) do |waybill|
      waybill.car_number = 'WDW842'
    end
    # driver name
    validable_test('driver name error', @waybill, :driver_name, true) do |waybill|
      waybill.transport_type_id = RS::TransportType::VEHICLE
    end
    validable_test('fix driver name error', @waybill, :driver_name, false) do |waybill|
      waybill.driver_name = 'Dimitri Kurashvili'
    end
    # driver TIN
    validable_test('driver tin error', @waybill, :driver_tin, true)
    validable_test('driver tin error fix', @waybill, :driver_tin, false) do |waybill|
      waybill.driver_tin = '123456789'
    end
    validable_test('driver tin error again: when checking TIN', @waybill, :driver_tin, true) do |waybill|
      waybill.check_driver_tin = true
    end
    # transport name for RS::TransportType::OTHERS
    validable_test('transport name missing', @waybill, :transport_type_name, true) do |waybill|
      waybill.transport_type_id = RS::TransportType::OTHERS
    end
    validable_test('transport name missing: fix', @waybill, :transport_type_name, false) do |waybill|
      waybill.transport_type_name = 'horse'
    end
    # start/end address
    validable_test('start address is missing', @waybill, :start_address, true)
    validable_test('end address is missing', @waybill, :end_address, true)
    validable_test('fixing start address', @waybill, :start_address, false) do |waybill|
      waybill.start_address = 'Tbilisi'
    end
    validable_test('fixing end address', @waybill, :end_address, false) do |waybill|
      waybill.end_address = 'Sokhumi'
    end
    # items
    validable_test('items are missing', @waybill, :items, true)
  end
end

describe 'waybill item validation' do
  before(:all) do
    @item = RS::WaybillItem.new
    @item.validate
  end
  subject { @item }
  it { should_not be_valid }
end
