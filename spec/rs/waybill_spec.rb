# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'rs'

def waybill_skeleton(params = {})
  waybill = RS::Waybill.new
  waybill.id = params[:id]
  waybill.type = params[:type] ? params[:type] : RS::WaybillType::TRANSPORTATION
  waybill.status = params[:status] ? params[:status] : RS::Waybill::STATUS_SAVED
  waybill.seller_id = params[:seller_id] ? params[:seller_id] : 731937
  waybill.buyer_tin = params[:buyer_tin] ? params[:buyer_tin] : '12345678910'
  waybill.check_buyer_tin = params[:check_buyer_tin] ? params[:check_buyer_tin] : true
  waybill.buyer_name = params[:buyer_name] ? params[:buyer_name] : 'სატესტო მყიდველი'
  waybill.start_address = params[:start_address] ? params[:start_address] : 'თბილისი'
  waybill.end_address   = params[:end_address] ? params[:end_address] : 'სოხუმი'
  waybill.transport_type_id = params[:transport_type] ? params[:transport_type] : RS::TransportType::VEHICLE
  waybill.start_date = params[:start_date] ? params[:start_date] : Time.now
  if waybill.transport_type_id == RS::TransportType::VEHICLE
    waybill.car_number = params[:car_number] ? params[:car_number] : 'WDW842'
    waybill.driver_name = params[:driver_name] ? params[:driver_name] : 'დიმიტრი ყურაშვილი'
    waybill.driver_tin = params[:driver_tin] ? params[:driver_tin] : '02001000490'
  else
    waybill.car_number = params[:car_number]
    waybill.driver_name = params[:driver_name]
    waybill.driver_tin = params[:driver_tin]
  end

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

describe 'save waybill' do
  before(:all) do
    @waybill = waybill_skeleton
    RS.save_waybill(@waybill, RS.su_params)
  end
  subject { @waybill }
  its(:status) { should == 0 }
  its(:id) { should_not be_nil }
  its(:id) { should > 0 }
  its(:error_code) { should == 0 }
  context 'items' do
    subject { @waybill.items }
    its(:size) { should == 1 }
    context 'first item' do
      subject { @waybill.items.first }
      its(:id) { should_not be_nil }
      its(:id) { should > 0 }
    end
  end
end

describe 'save waybill with large production name' do
  before(:all) do
    @waybill = waybill_skeleton
    @waybill.items[0].prod_name = '1234567890'*30 + '1' # 301 სიმბოლო შეცდომითია
    RS.save_waybill(@waybill, RS.su_params)
  end
  subject { @waybill }
  its(:error_code) { should == -1 }
  its(:id) { should be_nil }
end
