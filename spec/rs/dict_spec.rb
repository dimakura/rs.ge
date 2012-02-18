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
