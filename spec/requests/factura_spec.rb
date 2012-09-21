# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'get factura' do
  before(:all) do
    @id = 16658260
    @factura = RS.fact.get_factura(id: @id, user_id: DEFAULT_USERID)
    
  end
  subject { @factura }
  it { should_not be_nil }
  its(:index) { should == 'ეა-36'}
  its(:number) { should be_nil }
  its(:operation_date) { should_not be_nil }
  its(:registration_date) { should_not be_nil }
  its(:seller_id) { should == 731937 }
  its(:status) { should == 0 }
  its(:waybill_number) { should == '84' }
  its(:waybill_date) { should_not be_nil }
  its(:correction_of) { should be_nil }
end
