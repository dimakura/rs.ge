# -*- encoding : utf-8 -*-
require 'spec_helper'

def create_waybill(opts = {})
  
end

def create_item(opts = {})
  RS::WaybillItem.new( id: opts[:id] || 0,
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
    @waybill = RS::Waybill.new(id: 0, type: RS::WAYBILL_TYPE_TRANS, status: RS::Waybill::STATUS_SAVED,
      seller_id: USER01[:payer], seller_tin: USER01[:payer_tin], seller_name: USER01[:payer_name],
      buyer_tin: '02001000490', buyer_name: 'დიმიტრი ყურაშვილი', check_buyer_tin: true,
      seller_info: 'ვიტალი ხორავა', buyer_info: 'გოდერძი მამიაშვილი',
      driver_tin: '02001000490', check_driver_tin: true, driver_name: 'დიმიტრი ყურაშვილი',
      start_address: 'ქ. აბაშა, კაჭარავას 35', end_address: 'ქ. სენაკი, თავისუფლების 10',
      transportation_cost: 10, transportation_cost_payer: 1, transport_type_id: RS::TRANS_VEHICLE,
      car_number: 'wdw842', comment: 'ჩემი კომენტარი', user_id: USER01[:id],
      items: [create_item(bar_code: '001', prod_name: 'Tomato'), create_item(bar_code: '002', prod_name: 'Cucumber')])
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
end