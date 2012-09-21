# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'get factura' do
  context do
    before(:all) do
      @id = 16658260
      @factura = RS.fact.get_factura(id: @id, user_id: DEFAULT_USERID)
    end
    subject { @factura }
    it { should_not be_nil }
    its(:id) { should == @id }
    its(:index) { should == 'ეა-36'}
    its(:number) { should be_nil }
    its(:operation_date) { should_not be_nil }
    its(:registration_date) { should_not be_nil }
    its(:seller_id) { should == 731937 }
    its(:status) { should == RS::Factura::STATUS_START }
    its(:waybill_number) { should == '84' }
    its(:waybill_date) { should_not be_nil }
    its(:correction_of) { should be_nil }
  end
  context do
    before(:all) do
      @id = 16953719
      @factura = RS.fact.get_factura(id: @id, user_id: DEFAULT_USERID)
    end
    subject { @factura }
    it { should_not be_nil }
    its(:id) { should == @id }
    its(:index) { should == 'ეა-36'}
    its(:number) { should == 269554 }
    its(:operation_date) { should_not be_nil }
    its(:registration_date) { should_not be_nil }
    its(:seller_id) { should == 731937 }
    its(:status) { should == RS::Factura::STATUS_SENT }
    its(:correction_of) { should be_nil }
  end
end
