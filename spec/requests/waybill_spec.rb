# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'Save waybill' do
  before(:all) do
    @waybill = RS::Waybill.new(id: 0)
    @waybill.id = 0
    @waybill.type = RS::WAYBILL_TYPE_TRANS
    @waybill.parent_id = nil
    @waybill.status = RS::Waybill::STATUS_SAVED
    @waybill.seller_id = USER01[:payer]
    @waybill.seller_tin = USER01[:payer_tin]
    @waybill.seller_name = USER01[:payer_name]
    @waybill.buyer_tin = '02001000490'
    @waybill.buyer_name = 'დიმიტრი ყურაშვილი'
    @waybill.check_buyer_tin = true
    @waybill.seller_info = 'ვიტალი ხორავა'
    @waybill.buyer_info = 'გოდერძი მამიაშვილი'
    @waybill.driver_tin = '02001000490'
    @waybill.check_driver_tin = true
    @waybill.driver_name = 'დიმიტრი ყურაშვილი'
    @waybill.start_address = 'ქ. აბაშა, კაჭარავას 35'
    @waybill.end_address = 'ქ. სენაკი, თავისუფლების 10'
    @waybill.transportation_cost = 10
    @waybill.transportation_cost_payer = 1
    @waybill.transport_type_id = RS::TRANS_VEHICLE
    @waybill.transport_type_name = nil
    @waybill.car_number = 'wdw842'
    @waybill.comment = 'ჩემი კომენტარი'
    @waybill.user_id = USER01[:id]
    
    @item_01 = RS::WaybillItem.new
    @item_01.id = 0
    @item_01.bar_code = '001'
    @item_01.prod_name = 'Tomato'
    @item_01.unit_id = RS::UNIT_OTHERS
    @item_01.unit_name = 'kg'
    @item_01.quantity = 10
    @item_01.price = 5
    @item_01.excise_id = 0
    @item_01.vat_type = RS::VAT_COMMON
    @item_01.delete = false

    @waybill.items = [@item_01]

    RS.wb.save_waybill(@waybill)
  end
  subject { @waybill }
  its(:id) { should_not be_nil }
  its(:id) { should > 0 }
  its(:error_code) { should == 0 }
end