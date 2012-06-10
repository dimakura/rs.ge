# -*- encoding : utf-8 -*-
require 'spec_helper'

def create_waybill(opts = {})
  RS::Waybill.new(id: opts[:id] || 0,
    type: opts[:type] || RS::WAYBILL_TYPE_TRANS,
    status: opts[:status] || RS::Waybill::STATUS_SAVED,
    seller_id: USER01[:payer], seller_tin: USER01[:payer_tin], seller_name: USER01[:payer_name],
    buyer_tin: opts[:buyer_tin] || '02001000490',
    buyer_name: opts[:buyer_name] || 'დიმიტრი ყურაშვილი',
    check_buyer_tin: true,
    seller_info: opts[:seller_info], buyer_info: opts[:buyer_info],
    driver_tin: opts[:dirver_tin] || '02001000490',
    driver_name: opts[:dirver_name] || 'დიმიტრი ყურაშვილი',
    check_driver_tin: true,
    start_address: opts[:start_address] || 'ქ. აბაშა, კაჭარავას 35',
    end_address: opts[:end_address] || 'ქ. სენაკი, თავისუფლების 10',
    transportation_cost: opts[:transportation_cost] || 0,
    transportation_cost_payer: opts[:transportation_cost_payer] || 1,
    transport_type_id: opts[:transport_type_id] || RS::TRANS_VEHICLE,
    car_number: opts[:car_number] || 'wdw842',
    comment: opts[:comment], user_id: USER01[:id],
    items: opts[:items]
  )
end

def create_item(opts = {})
  RS::WaybillItem.new(id: opts[:id] || 0,
    bar_code: opts[:bar_code] || '001',
    prod_name: opts[:prod_name] || 'Tomato',
    unit_id: opts[:unit_id] || RS::UNIT_OTHERS,
    unit_name: opts[:unit_name] || 'kg',
    quantity: opts[:quantity] || 1,
    price: opts[:price] || 1,
    vat_type: opts[:vat_type] || RS::VAT_COMMON,
    delete: false
  )
end

describe 'Save waybill' do
  before(:all) do
    items = [create_item(bar_code: '001', prod_name: 'პამიდორი', price: 2, quantity: 5), create_item(bar_code: '002', prod_name: 'კიტრი', price: 3, quantity: 10)]
    @waybill = create_waybill(items: items)
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
      @resp = RS.wb.activate_waybill(id: @waybill.id, date: Time.now)
      @waybill = RS.wb.get_waybill(id: @waybill.id)
    end
    subject { @waybill }
    its(:id) { should_not be_nil }
    its(:total) { should == 4800 }
    its(:number) { should_not be_nil }
    its(:number) { should == @resp }
    its(:status) { should == RS::Waybill::STATUS_ACTIVE }
    its(:activate_date) { should_not be_nil }
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
    subject { @waybill }
    its(:id) { should_not be_nil }
    its(:total) { should == 4800 }
    its(:number) { should_not be_nil }
    its(:number) { should == @resp }
    its(:status) { should == RS::Waybill::STATUS_ACTIVE }
    its(:activate_date) { should_not be_nil }
  end
end
