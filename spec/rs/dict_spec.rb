# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'getting excise codes' do
  before(:all) do
    @codes = RS.get_excise_codes(RS.su_params)
  end
  subject { @codes }
  it { should_not be_nil }
  it { should_not be_empty }
  context "first code" do
    subject {@codes.first}
    it { should be_instance_of RS::ExciseCode }
    its(:id)      { should_not be_nil }
    its(:name)    { should_not be_nil }
    its(:name)    { should_not be_empty }
    its(:code)    { should_not be_empty }
    its(:measure) { should_not be_nil }
    its(:value)   { should_not be_nil }
    its(:value)   { should > 0 }
  end
end

describe 'excise name normalization' do
  context 'name (1234) _ msr _ (1)' do
    subject { RS.normalize_excise_name('name (1234) _ msr _ (1)') }
    it { should == 'name' }
  end
  context 'name       (019048999) _     msr _ (1)' do
    subject { RS.normalize_excise_name('name       (019048999) _     msr _ (1)') }
    it { should == 'name' }
  end
end

describe 'getting waybill types' do
  before(:all) do
    @types = RS.get_waybill_types(RS.su_params)
  end
  subject { @types }
  it { should_not be_nil }
  it { should_not be_empty  }
  context 'first type' do
    subject { @types.first }
    it { should be_instance_of WaybillType }
    its(:id)   { should_not be_nil }
    its(:name) { should_not be_nil }
    its(:name) { should_not be_empty }
  end
end

def waybill_type_creation_test(id)
  context "WaybillType with ID=#{id}" do
    subject { WaybillType.create_from_id(id) }
    it { should be_instance_of WaybillType }
    its(:id) { should ==  id }
    its(:name) { should == WaybillType::NAMES[id]}
  end
end

describe WaybillType do
  waybill_type_creation_test WaybillType::INNER
  waybill_type_creation_test WaybillType::TRANSPORTATION
  waybill_type_creation_test WaybillType::WITHOUT_TRANSPORTATION
  waybill_type_creation_test WaybillType::DISTRIBUTION
  waybill_type_creation_test WaybillType::RETURN
  waybill_type_creation_test WaybillType::SUB_WAYBILL
end

describe 'getting waybill units' do
  before(:all) do
    @units = RS.get_waybill_units(RS.su_params)
  end
  subject { @units }
  it { should_not be_nil }
  it { should_not be_empty }
  context 'first unit' do
    subject{ @units.first }
    it { should_not be_nil }
    it { should be_instance_of WaybillUnit }
    its(:id)   { should_not be_nil }
    its(:name) { should_not be_nil }
    its(:name) { should_not be_empty }
  end
end

describe 'getting transport types' do
  before(:all) do
    @types = RS.get_transport_types(RS.su_params)
  end
  subject { @types }
  it { should_not be_nil }
  it { should_not be_empty }
  context 'first type' do
    subject { @types.first }
    it { should_not be_nil }
    it { should be_instance_of TransportType }
    its(:id) { should_not be_nil }
    its(:name) { should_not be_nil }
    its(:name) { should_not be_empty }
  end
end
