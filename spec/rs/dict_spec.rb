# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'getting aqcizi codes' do
  before(:all) do
    @codes = RS.get_excise_codes(RS.su_params)
  end
  subject { @codes }
  it { should_not be_nil }
  it { should_not be_empty }
  context "first code" do
    subject {@codes.first}
    it { should be_instance_of RS::ExciseCode }
    it { subject.id.should_not be_nil }
    it { subject.name.should_not be_nil }
    it { subject.measure.should_not be_nil }
    it { subject.name.should_not be_nil }
    it { subject.value.should_not be_nil }
    it { subject.value.should > 0 }
  end
end
