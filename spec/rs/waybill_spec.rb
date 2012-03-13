# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'rs'

RSpec::Matchers.define :be_valid_personal_tin do #|expected|
  match do |actual|
    RS.is_valid_personal_tin(actual)
  end
end

RSpec::Matchers.define :be_valid_corporate_tin do #|expected|
  match do |actual|
    RS.is_valid_corporate_tin(actual)
  end
end

def validate_personal_tin(tin, valid=true)
  if valid
    context "#{tin} should be valid" do
      subject{ tin }
      it { should be_valid_personal_tin }
    end
  else
    context "#{tin} should NOT be valid" do
      subject{ tin }
      it { should_not be_valid_personal_tin }
    end
  end
end

def validate_corporate_tin(tin, valid=true)
  if valid
    context "#{tin} should be valid" do
      subject{ tin }
      it { should be_valid_corporate_tin }
    end
  else
    context "#{tin} should NOT be valid" do
      subject{ tin }
      it { should_not be_valid_corporate_tin }
    end
  end
end

describe 'Personal TIN validation' do
  validate_personal_tin('12345678901',  true)
  validate_personal_tin('1234567890',   false)
  validate_personal_tin('123456789012', false)
  validate_personal_tin('1234567890A', false)
end

describe 'Corporate TIN validation' do
  validate_corporate_tin('123456789',  true)
  validate_corporate_tin('1234567890', false)
  validate_corporate_tin('12345678',   false)
  validate_corporate_tin('12345678A',  false)
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
    #puts @waybill.id
  end
  subject { @waybill }
  # გაუგებარია რატომ გააკეთეს ასე ?!
  its(:error_code) { should == 0 }
  # ID არის ცარიელი
  its(:id) { should  be_nil }
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

describe 'activate waybill' do
  before(:all) do
    @waybill = waybill_skeleton
    RS.save_waybill(@waybill, RS.su_params)
    wb_params = RS.su_params.merge({ 'waybill_id' => @waybill.id })
    RS.activate_waybill(wb_params)
    @waybill = RS.get_waybill(wb_params)
  end
  subject { @waybill }
  its(:status) { should == RS::Waybill::STATUS_ACTIVE }
end

describe 'close waybill' do
  before(:all) do
    @waybill = waybill_skeleton
    RS.save_waybill(@waybill, RS.su_params)
    @wb_params = RS.su_params.merge({ 'waybill_id' => @waybill.id })
    RS.activate_waybill(@wb_params)
    @resp = RS.close_waybill(@wb_params)
  end
  subject { @resp }
  it { should == true }
  context "waybill itself" do
    before(:all) do
      @waybill = RS.get_waybill(@wb_params)
    end
    subject { @waybill }
    its(:status) { should == RS::Waybill::STATUS_CLOSED }
  end
end

describe 'delete saved waybill' do
  before(:all) do
    @waybill = waybill_skeleton
    RS.save_waybill(@waybill, RS.su_params)
    @wb_params = RS.su_params.merge({ 'waybill_id' => @waybill.id })
    @resp = RS.delete_waybill(@wb_params)
  end
  subject { @resp }
  it { should == true }
  context "where is waybill" do
    before(:all) do
      @deleted = RS.get_waybill(@wb_params)
    end
    subject { @deleted }
    it { should_not be_nil}
    its(:status) { should == RS::Waybill::STATUS_DELETED }
  end
end
