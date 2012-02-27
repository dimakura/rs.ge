# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'rs'

describe 'create waybill, activate it, then deactivate' do
  before(:all) do
    @waybill = waybill_skeleton
    RS.save_waybill(@waybill, RS.su_params)
  end
  subject { @waybill }
  it { should_not be_nil }
  its(:id) { should_not be_nil }
  its(:status) { should == RS::Waybill::STATUS_SAVED }
  context 'activate waybill' do
    before(:all) do
      params = RS.su_params.merge('waybill_id' => @waybill.id)
      RS.activate_waybill(params)
      @waybill = RS.get_waybill(params)
    end
    subject { @waybill }
    its(:status) { should == RS::Waybill::STATUS_ACTIVE }
  end
  context 'now deactivate waybill' do
    before(:all) do
      params = RS.su_params.merge('waybill_id' => @waybill.id)
      #RS.close_waybill(params)
      RS.deactivate_waybill(params)
      @waybill = RS.get_waybill(params)
    end
    subject { @waybill }
    its(:status) { should == RS::Waybill::STATUS_DEACTIVATED }
  end
end

describe 'create waybill, activate and close it, then try to deactivate' do
  before(:all) do
    @waybill = waybill_skeleton
    RS.save_waybill(@waybill, RS.su_params)
  end
  subject { @waybill }
  it { should_not be_nil }
  its(:id) { should_not be_nil }
  its(:status) { should == RS::Waybill::STATUS_SAVED }
  context 'activate and close waybill' do
    before(:all) do
      params = RS.su_params.merge('waybill_id' => @waybill.id)
      RS.activate_waybill(params)
      RS.close_waybill(params)
      @waybill = RS.get_waybill(params)
    end
    subject { @waybill }
    its(:status) { should == RS::Waybill::STATUS_CLOSED }
  end
  context 'could not deactivate closed waybill !!' do
    before(:all) do
      params = RS.su_params.merge('waybill_id' => @waybill.id)
      RS.deactivate_waybill(params)
      @waybill = RS.get_waybill(params)
    end
    subject { @waybill }
    its(:status) { should == RS::Waybill::STATUS_CLOSED }
  end
end
