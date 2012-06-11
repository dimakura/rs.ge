# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'Save invoice' do
  before(:all) do
    @waybill = create_waybill(items: [create_item])
    RS.wb.save_waybill(@waybill)
    RS.wb.activate_waybill(id: @waybill.id)
    RS.wb.close_waybill(id: @waybill.id)
    @waybill = RS.wb.get_waybill(id: @waybill.id)
    @invoice_id = RS.wb.save_invoice(id: @waybill.id)
  end
  context 'Analyze' do
    subject { @invoice_id }
    it { should_not be_nil }
    it { should > 0 }
  end
  context 'update waybill' do
    before(:all) do
      @waybill.items[0].price = 10
      @waybill.items[0].quantity = 5
      @resp = RS.wb.save_waybill(@waybill)
      @waybill = RS.wb.get_waybill(id: @waybill.id)
    end
    subject { @waybill }
    its(:error_code) { should be_nil }
    its(:total) { should == 50 }
  end
  context 'update invoice' do
    before(:all) do
      @new_invoice_id = RS.wb.save_invoice(id: @waybill.id, invoice_id: @invoice_id)
    end
    subject { @new_invoice_id }
    it { should == @invoice_id }
  end
end
