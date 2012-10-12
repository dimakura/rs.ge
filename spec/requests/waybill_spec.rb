# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'Save waybill' do
  before(:all) do
    items = [create_item(bar_code: '001', prod_name: 'პამიდორი', price: 2, quantity: 5), create_item(bar_code: '002', prod_name: 'კიტრი', price: 3, quantity: 10)]
    @waybill = create_waybill(transport_type_id: RS::TRANS_VEHICLE, car_number: 'abc123', car_number_trailer: 'de45', items: items)
    RS.wb.save_waybill(@waybill)
  end
  context 'waybill' do
    subject { @waybill }
    its(:id) { should_not be_nil }
    its(:id) { should > 0 }
    its(:error_code) { should == 0 }
  end
  context 'items' do
    subject { @waybill.items.first }
    its(:id) { should_not be_nil }
    its(:id) { should > 0 }
  end
  context 'get this waybill' do
    before(:all) do
      @waybill = RS.wb.get_waybill(id: @waybill.id)
    end
    subject { @waybill }
    it { should_not be_nil }
    its(:id) { should > 0 }
    its(:number) { should be_nil }
    its(:status) { should == RS::Waybill::STATUS_SAVED }
    its(:total) { should == 40 }
    its(:create_date) { should_not be_nil }
    its(:create_date) { should be_instance_of DateTime }
    its(:activate_date) { should be_nil }
    its(:close_date) { should be_nil }
    its(:delivery_date) { should be_nil }
    its(:car_number) { should == 'abc123' }
    its(:car_number_trailer) { should == 'de45' }
  end
end

describe 'Resave waybill' do
  before(:all) do
    items = [create_item(bar_code: '100', prod_name: 'მობილური', price: 500, quantity: 1), create_item(bar_code: '101', prod_name: 'Kingston RAM/4GB/DDR3', price: 45, quantity: 2)]
    @waybill = create_waybill(items: items)
    RS.wb.save_waybill(@waybill)
    @waybill = RS.wb.get_waybill(id: @waybill.id)
    @initial_id = @waybill.id
  end
  context 'After initial save' do
    subject { @waybill }
    its(:total) { should == 590 }
    specify { subject.items.size.should == 2 }
  end
  context 'Delete first item and update second' do
    before(:all) do
      @waybill.items[0].delete = true
      @waybill.items[1].quantity = 3
      @waybill.items[1].price = 50
      RS.wb.save_waybill(@waybill)
      @waybill = RS.wb.get_waybill(id: @waybill.id)
    end
    subject { @waybill }
    its(:id) { should == @initial_id }
    its(:total) { should == 150 }
    specify { subject.items.size.should == 1 }
  end
end
 
describe 'Activate waybill' do
  context 'with begin_date' do
    before(:all) do
      items = [
        create_item(bar_code: '001', prod_name: 'iPhone 4S 3G/32GB', price: 1800, quantity: 2),
        create_item(bar_code: '002', prod_name: 'The New iPad 3G/16GB', price: 1200, quantity: 1)
      ]
      @waybill = create_waybill(items: items)
      RS.wb.save_waybill(@waybill)
      @resp = RS.wb.activate_waybill(id: @waybill.id, date: Time.now + 1800)
      @waybill = RS.wb.get_waybill(id: @waybill.id)
    end
    subject { @waybill }
    its(:id) { should_not be_nil }
    its(:total) { should == 4800 }
    its(:number) { should_not be_nil }
    its(:number) { should == @resp }
    its(:status) { should == RS::Waybill::STATUS_ACTIVE }
    its(:activate_date) { should_not be_nil }
    its(:delivery_date) { should be_nil }
  end
  context 'without begin_date' do
    before(:all) do
      items = [
        create_item(bar_code: '001', prod_name: 'iPhone 4S 3G/32GB', price: 1800, quantity: 2),
        create_item(bar_code: '002', prod_name: 'The New iPad 3G/16GB', price: 1200, quantity: 1)
      ]
      @waybill = create_waybill(items: items)
      RS.wb.save_waybill(@waybill)
      @resp = RS.wb.activate_waybill(id: @waybill.id)
      @waybill = RS.wb.get_waybill(id: @waybill.id)
    end
    context 'analyze' do
      subject { @waybill }
      its(:id) { should_not be_nil }
      specify { subject.items.size.should == 2 }
      its(:total) { should == 4800 }
      its(:number) { should_not be_nil }
      its(:number) { should == @resp }
      its(:status) { should == RS::Waybill::STATUS_ACTIVE }
      its(:activate_date) { should_not be_nil }
      its(:delivery_date) { should be_nil }
    end
    context 'edit active waybill' do
      before(:all) do
        @waybill.items[1].delete = true
        @waybill.items[0].quantity = 1
        @waybill.items[0].price = 1000
        RS.wb.save_waybill(@waybill)
        @waybill = RS.wb.get_waybill(id: @waybill.id)
      end
      subject { @waybill }
      specify { subject.items.size.should == 1 }
      its(:total) { should == 1000 }
      its(:status) { should == RS::Waybill::STATUS_ACTIVE }
      its(:number) { should == @resp }
    end
  end
end

describe 'Close waybill' do
  context 'with delivery_date' do
    before(:all) do
      items = [
        create_item(bar_code: '001', prod_name: 'iPhone 4S 3G/32GB', price: 1800, quantity: 2),
        create_item(bar_code: '002', prod_name: 'The New iPad 3G/16GB', price: 1200, quantity: 1)
      ]
      waybill = create_waybill(items: items)
      RS.wb.save_waybill(waybill)
      RS.wb.activate_waybill(id: waybill.id, date: Time.now + 1800)
      @resp = RS.wb.close_waybill(id: waybill.id, date: Time.now + 3600)
      @waybill = RS.wb.get_waybill(id: waybill.id)
    end
    subject { @waybill }
    its(:id) { should_not be_nil }
    its(:total) { should == 4800 }
    its(:number) { should_not be_nil }
    its(:status) { should == RS::Waybill::STATUS_CLOSED }
    its(:activate_date) { should_not be_nil }
    its(:delivery_date) { should_not be_nil }
    specify { @resp.should == true }
  end
  context 'without delivery_date' do
    before(:all) do
      items = [
        create_item(bar_code: '001', prod_name: 'iPhone 4S 3G/32GB', price: 1800, quantity: 2),
        create_item(bar_code: '002', prod_name: 'The New iPad 3G/16GB', price: 1200, quantity: 1)
      ]
      @waybill = create_waybill(items: items)
      RS.wb.save_waybill(@waybill)
      RS.wb.activate_waybill(id: @waybill.id)
      @resp = RS.wb.close_waybill(id: @waybill.id)
      @waybill = RS.wb.get_waybill(id: @waybill.id)
    end
    subject { @waybill }
    its(:id) { should_not be_nil }
    its(:total) { should == 4800 }
    its(:number) { should_not be_nil }
    specify { @resp.should == true }
    its(:status) { should == RS::Waybill::STATUS_CLOSED }
    its(:activate_date) { should_not be_nil }
    its(:delivery_date) { should_not be_nil }
  end
end

describe 'Delete waybill' do
  context 'save and delete' do
    before(:all) do
      @waybill = create_waybill(items: [create_item])
      RS.wb.save_waybill(@waybill)
      @resp = RS.wb.delete_waybill(id: @waybill.id)
      @waybill = RS.wb.get_waybill(id: @waybill.id)
    end
    subject { @waybill }
    specify { @resp.should == true }
    its(:status) { should == RS::Waybill::STATUS_DELETED }
  end
  context 'save, activate and delete' do
    before(:all) do
      @waybill = create_waybill(items: [create_item])
      RS.wb.save_waybill(@waybill)
      RS.wb.activate_waybill(id: @waybill.id)
      @resp = RS.wb.delete_waybill(id: @waybill.id)
      @waybill = RS.wb.get_waybill(id: @waybill.id)
    end
    subject { @waybill }
    specify { @resp.should == false }
    its(:status) { should == RS::Waybill::STATUS_ACTIVE }
  end
end

describe 'Deactivate waybill' do
  context 'save, activate and deactivate waybill' do
    before(:all) do
      @waybill = create_waybill(items: [create_item])
      RS.wb.save_waybill(@waybill)
      RS.wb.activate_waybill(id: @waybill.id)
      @resp = RS.wb.deactivate_waybill(id: @waybill.id)
      @waybill = RS.wb.get_waybill(id: @waybill.id)
    end
    subject { @waybill }
    specify { @resp.should == true }
    its(:status) { should == RS::Waybill::STATUS_DEACTIVATED }
  end
end
