# -*- encoding : utf-8 -*-
require 'spec_helper'

def waybill_skeleton(params)
  waybill = Waybill.new
  waybill.id = params[:id]
  waybill.type = params[:type] ? params[:type] : RS::WaybillType::TRANSPORTATION
  waybill.status = params[:status] ? params[:status] : RS::Waybill::STATUS_START
  waybill.seller_id = 731937
  waybill.buyer_tin = '12345678910'
  waybill.check_buyer_tin = true
  waybill.buyer_name = 'სატესტო ორგანიზაცია - 2'
  waybill.start_address = params[:start_address] ? params[:start_address] : 'თბილისი'
  waybill.end_address   = params[:end_address] ? params[:end_address] : 'სოხუმი'
  waybill.transport_type_id = params[:transport_type] ? params[:transport_type] : RS::TransportType::VEHICLE
  waybill.start_date = params[:start_date] ? params[:start_date] : Time.now

  if params[:items]
    items = []
    params[:items].each do |item|
      item = WaybillItem.new
      item.prod_name = item[:name]
      item.unit_id = item[:unit_id]
      item.unit_name = item[:unit_name]
      item.quantity = item[:quantity]
      item.price = item[:price]
      item.bar_code = item[:code]
      items << item
    end
  else
    item = WaybillItem.new
    item.prod_name = 'სატესტო საქონელი'
    item.unit_id = 99
    item.unit_name = 'ერთეული'
    item.quantity = 2
    item.price = 5
    item.bar_code = '123'
    items = [item]
  end
  waybill.items = items

  waybill
end

describe 'save waybill' do
  # TODO:
end
