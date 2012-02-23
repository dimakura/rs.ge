# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'rs'

def waybill_skeleton(params = {})
  waybill = RS::Waybill.new
  waybill.id = params[:id]
  waybill.type = params[:type] || RS::WaybillType::TRANSPORTATION
  waybill.status = params[:status] || RS::Waybill::STATUS_SAVED
  waybill.seller_id = params[:seller_id] || 731937
  waybill.buyer_tin = params[:buyer_tin] || '12345678910'
  waybill.check_buyer_tin = params[:check_buyer_tin] ? params[:check_buyer_tin] : true
  waybill.buyer_name = params[:buyer_name] || 'სატესტო მყიდველი'
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

describe 'get waybill information' do
  before(:all) do
    @start = waybill_skeleton({:comment => 'სატესტო კომენტარი'})
    @item = @start.items.first
    RS.save_waybill(@start, RS.su_params)
    @waybill = RS.get_waybill(RS.su_params.merge('waybill_id' => @start.id))
  end
  subject { @waybill }
  it { should_not be_nil }
  its(:id) { should_not be_nil }
  its(:type) { should == @start.type }
  its(:create_date) { should_not be_nil } 
  its(:status) { should == RS::Waybill::STATUS_SAVED }
  its(:parent_id) { should be_nil }
  its(:seller_id) { should == @start.seller_id }
  its(:buyer_tin) { should == @start.buyer_tin }
  its(:buyer_name) { should == @start.buyer_name }
  its(:check_buyer_tin) { should == @start.check_buyer_tin }
  its(:seller_info) { should == @start.seller_info }
  its(:buyer_info) { should == @start.buyer_info }
  its(:driver_tin) { should == @start.driver_tin }
  its(:check_driver_tin) { should == @start.check_driver_tin }
  its(:driver_name) { should == @start.driver_name }
  its(:start_address) { should == @start.start_address }
  its(:end_address) { should == @start.end_address }
  its(:transportation_cost) { should == @start.transportation_cost }
  its(:transportation_cost_payer) { should == @start.transportation_cost_payer }
  its(:transport_type_id) { should == @start.transport_type_id }
  its(:transport_type_name) { should == @start.transport_type_name }
  its(:car_number) { should == @start.car_number }
  its(:comment) { should == @start.comment }
  its(:start_date) { should_not be_nil }
  its(:delivery_date) { should be_nil }
  context 'items' do
    subject { @waybill.items }
    it { should_not be_empty }
    its(:size) { should == 1 }
    context 'first item' do
      subject { @waybill.items.first }
      it { should be_instance_of RS::WaybillItem }
      its(:id) { should_not be_nil }
      its(:prod_name) { should == @item.prod_name }
      its(:unit_id) { should == @item.unit_id }
      its(:unit_name) { should == @item.unit_name }
      its(:quantity) { should == @item.quantity }
      its(:price) { should == @item.price }
      its(:bar_code) { should == @item.bar_code }
      its(:excise_id) { should == @item.excise_id}
    end
  end
end
