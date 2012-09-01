# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'Save waybill: without driver name' do
  before(:all) do
    items = [create_item(bar_code: '001', prod_name: 'პამიდორი', price: 2, quantity: 5), create_item(bar_code: '002', prod_name: 'კიტრი', price: 3, quantity: 10)]
    @waybill = create_waybill(items: items)
    @waybill.driver_name = nil
    RS.wb.save_waybill(@waybill)
  end
  subject { @waybill }
  its(:id) { should_not be_nil }
  its(:error_code) { should == 0 }
end

describe 'Save waybill: without driver name (and buyer is foreigner)' do
  before(:all) do
    items = [create_item(bar_code: '001', prod_name: 'პამიდორი', price: 2, quantity: 5), create_item(bar_code: '002', prod_name: 'კიტრი', price: 3, quantity: 10)]
    @waybill = create_waybill(items: items)
    @waybill.driver_name = nil
    @waybill.check_buyer_tin = false
    RS.wb.save_waybill(@waybill)
  end
  subject { @waybill }
  its(:id) { should == 0 }
  its(:error_code) { should == -1013 }
end
