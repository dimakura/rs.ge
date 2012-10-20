# -*- encoding : utf-8 -*-

ORG_01 = {id: 731937, tin: '206322102', name: 'სატესტო კოდი'}
ORG_02 = {id: -1, tin: '12345678910', name: 'სატესტო სატესტო'}
USER01 = {id: 46362, username: 'tbilisi', password: '123456', payer: ORG_01[:id], payer_tin: ORG_01[:tin], payer_name: ORG_01[:name]}

def create_waybill(opts = {})
  RS::Waybill.new(id: opts[:id] || 0,
    type: opts[:type] || RS::WAYBILL_TYPE_TRANS,
    status: opts[:status] || RS::Waybill::STATUS_SAVED,
    seller_id: USER01[:payer], seller_tin: USER01[:payer_tin], seller_name: USER01[:payer_name],
    buyer_tin: opts[:buyer_tin] || ORG_02[:tin],
    buyer_name: opts[:buyer_name] || ORG_02[:name],
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
    car_number_trailer: opts[:car_number_trailer] || '',
    comment: opts[:comment], user_id: USER01[:id],
    items: opts[:items],
    parent_id: opts[:parent_id]
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
