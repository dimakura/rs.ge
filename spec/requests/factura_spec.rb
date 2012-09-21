# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'get factura' do
  context 'new factura' do
    before(:all) do
      @factura = RS::Factura.new(seller_id: RS.config.payer_id, buyer_id: RS.dict.get_payer_info(tin: '12345678910')[:payer_id])
      RS.fact.save_factura(@factura)
      @factura = RS.fact.get_factura(id: @factura.id)
    end
    context 'test header' do
      subject { @factura }
      its(:id) { should_not be_nil }
      its(:id) { should > 0 }
      its(:index) { should == 'ეა-36'}
      its(:number) { should be_nil }
      its(:operation_date) { should_not be_nil }
      its(:registration_date) { should_not be_nil }
      its(:seller_id) { should == 731937 }
      its(:buyer_id) { should_not be_nil }
      its(:buyer_id) { should == 1149251 }
      its(:status) { should == RS::Factura::STATUS_START }
      its(:waybill_number) { should be_nil }
      its(:waybill_date) { should_not be_nil }
      its(:correction_of) { should be_nil }
    end
    context do
      before(:all) do
        @item = RS::FacturaItem.new(factura_id: @factura.id, name: 'tomato', unit: 'kg', quantity: 10, total: 100, vat: 18)
        RS.fact.save_factura_item(@item)
      end
      subject { @item }
      it { should_not be_nil }
      its(:id) { should_not be_nil }
      its(:id) { should > 0 }
      its(:id) { should be_instance_of Fixnum }
    end
  end
  context do
    before(:all) do
      @id = 16953719
      @factura = RS.fact.get_factura(id: @id)
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
  context do
    before(:all) do
      @id = 16166575
      @factura = RS.fact.get_factura(id: @id)
    end
    subject { @factura }
    it { should_not be_nil }
    its(:id) { should == @id }
    its(:index) { should == 'ეა-05'}
    its(:number) { should == 6413864 }
    its(:operation_date) { should_not be_nil }
    its(:registration_date) { should_not be_nil }
    its(:seller_id) { should == 1149251 }
    its(:buyer_id) { should == 731937 }
    its(:status) { should == RS::Factura::STATUS_CONFIRMED }
    its(:correction_of) { should be_nil }
  end
end
