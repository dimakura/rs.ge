# -*- encoding : utf-8 -*-
require 'spec_helper'

seller_id = RS.config.payer_id
factura_buyer_id = RS.dict.get_payer_info(tin: '12345678910')[:payer_id]

describe 'create factura with items' do
  before(:all) do
    @factura = RS::Factura.new(seller_id: seller_id, buyer_id: factura_buyer_id)
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
  context 'add item 1' do
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
  context 'add item 2' do
    before(:all) do
      @item = RS::FacturaItem.new(factura_id: @factura.id, name: 'cucumber', unit: 'kg', quantity: 8, total: 80, vat: 14.4)
      RS.fact.save_factura_item(@item)
    end
    subject { @item }
    it { should_not be_nil }
    its(:id) { should_not be_nil }
    its(:id) { should > 0 }
    its(:id) { should be_instance_of Fixnum }
  end
  context 'get factura items' do
    before(:all) do
      @items = RS.fact.get_factura_items(id: @factura.id)
    end
    context 'all items' do
      subject { @items }
      it { should_not be_nil }
      its(:size) { should == 2 }
    end
    context 'first item' do
      subject { @items[0] }
      it { should_not be_nil }
      its(:id) { should > 0 }
      its(:factura_id) { should == @factura.id }
      its(:name) { should == 'tomato' }
      its(:unit) { should == 'kg' }
      its(:quantity) { should == 10 }
      its(:total) { should == 100 }
      its(:vat) { should == 18 }
      its(:excise) { should == 0 }
      its(:excise_id) { should == 0 }
    end
  end
  context 'delete first item' do
    before(:all) do
      @items = RS.fact.get_factura_items(id: @factura.id)
      @resp  = RS.fact.delete_factura_item(id: @items.first.id, factura_id: @factura.id)
      @items = RS.fact.get_factura_items(id: @factura.id)
    end
    context do
      subject { @resp }
      it { should == true }
    end
    context do
      subject { @items }
      its(:size) { should == 1 }
    end
  end
end

describe 'get factura' do
  context 'new factura' do
    before(:all) do
      @factura = RS::Factura.new(seller_id: RS.config.payer_id, buyer_id: factura_buyer_id)
      RS.fact.save_factura(@factura)
      @factura = RS.fact.get_factura(id: @factura.id)
    end
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

describe 'change factura statuses' do
  before(:all) do
    @factura = RS::Factura.new(seller_id: seller_id, buyer_id: factura_buyer_id)
    RS.fact.save_factura(@factura)
    @item = RS::FacturaItem.new(factura_id: @factura.id, name: 'tomato', unit: 'kg', quantity: 10, total: 100, vat: 18)
    RS.fact.save_factura_item(@item)
  end
  context 'send factura' do
    before(:all) do
      @resp = RS.fact.send_factura(id: @factura.id)
      @factura = RS.fact.get_factura(id: @factura.id)
    end
    context do
      subject { @resp }
      it { should == true }
    end
    context do
      subject { @factura }
      it { should_not be_nil }
      its(:status) { should == RS::Factura::STATUS_SENT }
      its(:index) { should_not be_blank }
      its(:number) { should_not be_blank }
    end
  end
end
