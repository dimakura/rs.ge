# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'getting waybill units' do
  before(:all) do
    @units = RS.dict.units
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
    @types = RS.dict.waybill_types
  end
  subject { @types }
  it { should_not be_nil }
  it { should_not be_empty }
  its(:size) { should == RS::WAYBILL_TYPES.size }
end

describe 'getting transport types' do
  before(:all) do
    @types = RS.dict.transport_types
  end
  subject { @types }
  it { should_not be_nil }
  it { should_not be_empty }
  its(:size) { should == RS::TRANSPORT_TYPES.size }
end
 
describe 'getting payer name from tin' do
  before(:all) do
    @name = RS.dict.get_name_from_tin(tin: '02001000490')
  end
  subject { @name }
  it { should == 'დიმიტრი ყურაშვილი' }
end

describe 'payer_user_id testing' do
  before(:all) do
    @user_id = RS.dict.payer_user_id
  end
  subject { @user_id }
  it { should == DEFAULT_USERID }
end

RSpec::Matchers.define :be_personal_tin do
  match { |actual| RS.dict.personal_tin?(actual) }
end

RSpec::Matchers.define :be_corporate_tin do
  match { |actual| RS.dict.corporate_tin?(actual) }
end

describe 'quick TIN validations' do
  # personal
  specify { '02001000490'.should be_personal_tin }
  specify { '12345678901'.should be_personal_tin }
  specify { '1234567890'.should_not be_personal_tin }
  specify { '123456789012'.should_not be_personal_tin }
  # corporate
  specify { '422430239'.should be_corporate_tin }
  specify { '123456789'.should be_corporate_tin }
  specify { '1234567890'.should_not be_corporate_tin }
  specify { '12345678'.should_not be_corporate_tin }
end
