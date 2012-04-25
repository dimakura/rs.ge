# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'getting waybill units' do
  before(:all) do
    @units = RS.units.all(SU_PARAMS)
  end
  subject { @units }
  it { should_not be_nil }
  it { should_not be_empty }
  context 'first unit' do
    subject { @units.first }
    it { should be_instance_of RS::WaybillUnit }
    its(:id) { should_not be_nil }
    its(:name) { should_not be_nil }
  end
  context 'last unit' do
    subject { @units.last }
    it { should be_instance_of RS::WaybillUnit }
    its(:id) { should_not be_nil }
    its(:id) { should == RS::WaybillUnit::OTHERS }
    its(:name) { should_not be_nil }
  end
end
