# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'getting waybill units' do
  before(:all) do
    @units = RS.dict.units(SU_PARAMS)
  end
  subject { @units }
  it { should_not be_nil }
  it { should_not be_empty }
  context 'kg' do
    subject { @units[2] }
    it { should == 'კგ' }
  end
  context 'others' do
    subject { @units[RS::UNIT_OTHERS] }
    it { should == 'სხვა' }
  end
end

describe 'getting waybill types' do
  before(:all) do
    @types = RS.dict.waybill_types(SU_PARAMS)
  end
  subject { @types }
  it { should_not be_nil }
  it { should_not be_empty }
  its(:size) { should == RS::WAYBILL_TYPES.size }
end

describe 'getting payer name from tin' do
  before(:all) do
    @name = RS.dict.get_name_from_tin(SU_PARAMS.merge(tin: '02001000490'))
  end
  subject { @name }
  it { should == 'დიმიტრი ყურაშვილი' }
end