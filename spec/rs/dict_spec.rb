# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'rs'

# excise codes

describe 'excise name normalization' do
  context 'name 1 (1234) _ msr _ (1)' do
    subject { RS.normalize_excise_name('name 1 (1234) _ msr _ (1)') }
    it { should == 'name 1' }
  end
  context 'name 2      (019048999) _     msr _ (1)' do
    subject { RS.normalize_excise_name('name 2       (019048999) _     msr _ (1)') }
    it { should == 'name 2' }
  end
  context 'name 3 () _ msr __ ' do
    subject { RS.normalize_excise_name('name 3 () _ msr __ ') }
    it { should == 'name 3' }
  end
end

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

# waybill types

describe 'getting waybill types' do
  before(:all) do
    @types = RS.get_waybill_types(RS.su_params)
  end
  subject { @types }
  it { should_not be_nil }
  it { should_not be_empty  }
  context 'first type' do
    subject { @types.first }
    it { should be_instance_of RS::WaybillType }
    its(:id)   { should_not be_nil }
    its(:name) { should_not be_nil }
    its(:name) { should_not be_empty }
  end
end

def waybill_type_creation_test(id)
  context "WaybillType with ID=#{id}" do
    subject { RS::WaybillType.create_from_id(id) }
    it { should be_instance_of RS::WaybillType }
    its(:id) { should ==  id }
    its(:name) { should == RS::WaybillType::NAMES[id]}
  end
end

describe RS::WaybillType do
  waybill_type_creation_test RS::WaybillType::INNER
  waybill_type_creation_test RS::WaybillType::TRANSPORTATION
  waybill_type_creation_test RS::WaybillType::WITHOUT_TRANSPORTATION
  waybill_type_creation_test RS::WaybillType::DISTRIBUTION
  waybill_type_creation_test RS::WaybillType::RETURN
  waybill_type_creation_test RS::WaybillType::SUB_WAYBILL
end

# waybill units

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
    it { should be_instance_of RS::WaybillUnit }
    its(:id)   { should_not be_nil }
    its(:name) { should_not be_nil }
    its(:name) { should_not be_empty }
  end
end

# transport types

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
    it { should be_instance_of RS::TransportType }
    its(:id) { should_not be_nil }
    its(:name) { should_not be_nil }
    its(:name) { should_not be_empty }
  end
end

# bar codes

describe 'save and delete bar code' do
  before(:all) do
    @resp = RS.save_bar_code(RS.su_params.merge('bar_code' => '001', 'prod_name' => 'Apple', 'unit_id' => 1, 'unit_name' => 'kg', 'excise_id' => nil))
  end
  subject { @resp }
  it { should be_true }
  context 'delete this bar code' do
    before(:all) do
      @resp_delete = RS.delete_bar_code(RS.su_params.merge('bar_code' => 'inv/1'))
    end
    subject { @resp_delete }
    it { should be_true }
  end
end

describe 'get bar codes' do
  before(:all) do
    RS.save_bar_code(RS.su_params.merge({'bar_code' => 'TV1', 'prod_name' => 'tv set 1', 'unit_id' => RS::WaybillUnit::OTHERS, 'unit_name' => 'box'}))
    RS.save_bar_code(RS.su_params.merge({'bar_code' => 'TV2', 'prod_name' => 'tv set 2', 'unit_id' => RS::WaybillUnit::OTHERS, 'unit_name' => 'box'}))
  end
  context "look up first code" do
    before(:all) do
      @codes = RS.get_bar_codes(RS.su_params.merge({'bar_code' => 'TV1'}))
    end
    subject { @codes }
    it { should_not be_nil }
    it { should_not be_empty }
    its(:size) { should == 1 }
    context 'TV1 bar code' do
      subject { @codes.first }
      it { should be_instance_of RS::BarCode }
      its(:code) { should == 'TV1' }
      its(:name) { should == 'tv set 1' }
      its(:unit_id) { should == RS::WaybillUnit::OTHERS }
      its(:excise_id) { should be_nil }
    end
  end
  context "lookup both codes" do
    before(:all) do
      @codes = RS.get_bar_codes(RS.su_params.merge({'bar_code' => 'TV'}))
    end
    subject { @codes }
    it { should_not be_nil }
    it { should_not be_empty }
    its(:size) { should == 2 }
    context 'TV1 bar code' do
      subject { @codes.first }
      it { should be_instance_of RS::BarCode }
      its(:code) { should == 'TV1' }
      its(:name) { should == 'tv set 1' }
      its(:unit_id) { should == RS::WaybillUnit::OTHERS }
      its(:excise_id) { should be_nil }
    end
    context 'TV2 bar code' do
      subject { @codes[1] }
      it { should be_instance_of RS::BarCode }
      its(:code) { should == 'TV2' }
      its(:name) { should == 'tv set 2' }
      its(:unit_id) { should == RS::WaybillUnit::OTHERS }
      its(:excise_id) { should be_nil }
    end
  end
end
