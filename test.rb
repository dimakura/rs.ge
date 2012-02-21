# -*- encoding : utf-8 -*-
require 'savon'

client = Savon::Client.new 'http://services.rs.ge/WayBillService/WayBillService.asmx?WSDL'

wb = %Q{
        <WAYBILL>
             <SUB_WAYBILLS/>
             <GOODS_LIST>
                <GOODS>
                   <ID>0</ID>
                   <W_NAME>მწვანე ბარდა მარნეული  520გრ</W_NAME>
                   <UNIT_ID>2</UNIT_ID>
                   <UNIT_TXT>ცალი</UNIT_TXT>
                   <QUANTITY>1</QUANTITY>
                   <PRICE>2.09</PRICE>
                   <AMOUNT>2.09</AMOUNT>
                   <BAR_CODE>11</BAR_CODE>
                   <A_ID>0</A_ID>
                  </GOODS>
             </GOODS_LIST>
             <ID>0</ID>
             <TYPE>5</TYPE>
             <CREATE_DATE>2012-02-12T22:56:48</CREATE_DATE>
             <BUYER_TIN>211336240</BUYER_TIN>
             <CHEK_BUYER_TIN>0</CHEK_BUYER_TIN>
             <BUYER_NAME>ნიკორა</BUYER_NAME>
             <START_ADDRESS>ყანთელის 9</START_ADDRESS>
             <END_ADDRESS>ჭავჭავაძის 24</END_ADDRESS>
             <DRIVER_TIN>12345678910</DRIVER_TIN>
             <CHEK_DRIVER_TIN>0</CHEK_DRIVER_TIN>
             <DRIVER_NAME>დიმიტრი ობოლაშვილი</DRIVER_NAME>
             <TRANSPORT_COAST>0</TRANSPORT_COAST>
             <RECEPTION_INFO/>
             <RECEIVER_INFO/>
             <DELIVERY_DATE/>
             <STATUS>1</STATUS>
             <SELER_UN_ID>731937</SELER_UN_ID>
             <ACTIVATE_DATE/>
             <PAR_ID/>
             <CAR_NUMBER>ABK852</CAR_NUMBER>
             <BEGIN_DATE>2012-01-25T20:54:36</BEGIN_DATE>
             <TRAN_COST_PAYER>0</TRAN_COST_PAYER>
             <TRANS_ID>3</TRANS_ID>
             <TRANS_TXT/>
             <COMMENT/>
          </WAYBILL>
}

#resp = client.request 'get_waybill' do
#  soap.body = {'su'=>'dimitri1979','sp'=>'123456','waybill_id'=>'0000003171'}
#end

# resp = client.request 'SAVE_WAYBILL'.downcase do
#   soap.body = {
#     'su' => 'dimitri1979',
#     'sp' => '123456',
#     'waybill!' => wb
#   }
# end

#, :body => { 'waybill!' => '<a>Some XML</a>' }

# puts '-------------------'
# puts resp.to_hash
# puts '-------------------'
# puts resp.to_xml

body = { 'rs:save_waybill' => {'rs:su' => 'dimitri1979', 'rs:sp' => '123456', 'rs:waybill!' => wb }}
namespaces = { 'xmlns:soapenv' => 'http://schemas.xmlsoap.org/soap/envelope/', 'xmlns:rs' => 'http://tempuri.org/' }
wb_xml = Gyoku.xml( {'saopenv:Envelope' => { 'saopenv:Header' => {}, 'saopenv:Body' => body }, :attributes! => {'saopenv:Envelope' => namespaces}} )
#puts wb_xml
#resp = client.request 'save_waybill' do
#  soap.xml = %Q{<?xml version="1.0" encoding="utf-8"?>#{wb_xml}}
#end

# ეს არის ზედნადების ხაზი საქონლისთვის.
class WaybillItem
  attr_accessor :id, :prod_name, :unit_id, :unit_name, :quantity, :price, :bar_code, :excise_id
  attr_accessor :error_code, :status_code

  # აბრუნებს ამ ხაზის XML წარმოდგენას.
  # @param xml XML builder-ის კლასი
  def to_xml(xml)
    xml.GOODS do |b|
      b.ID (self.id ? self.id : 0)
      b.W_NAME self.prod_name
      b.UNIT_ID self.unit_id
      b.UNIT_TXT self.unit_name
      b.QUANTITY self.quantity
      b.PRICE self.price
      b.AMOUNT self.quantity * self.price
      b.BAR_CODE self.bar_code
      b.A_ID (self.excise_id ? self.excise_id : 0)
    end
  end
end

# ეს არის ზედნადების კლასი.
class Waybill
  TRANSPORTATION_PAID_BY_BUYER = 1
  TRANSPORTATION_PAID_BY_SELLER = 2
  STATUS_SAVED  = 0
  STATUS_ACTIVE = 1
  attr_accessor :id, :type, :status, :parent_id
  attr_accessor :seller_id # გამყიდველის უნიკალური კოდი
  attr_accessor :buyer_tin, :check_buyer_tin, :buyer_name
  attr_accessor :seller_info, :buyer_info # გამყიდველის/მყიდველის თანამდებობა, სახელი და გვარი
  attr_accessor :driver_tin, :check_driver_tin, :driver_name
  attr_accessor :start_address, :end_address
  attr_accessor :transportation_cost, :transportation_cost_payer, :transport_type_id, :transport_type_name, :car_number
  attr_accessor :comment
  attr_accessor :start_date, :delivery_date
  attr_accessor :items

  def to_xml(xml)
    xml.WAYBILL do |b|
      b.GOODS_LIST do |g|
        (self.items || []).each do |item|
          item.to_xml g
        end
      end
      b.ID (self.id ? self.id : 0)
      b.TYPE self.type
      b.BUYER_TIN self.buyer_tin
      b.CHEK_BUYER_TIN (self.check_buyer_tin ? 1 : 0)
      b.BUYER_NAME self.buyer_name
      b.START_ADDRESS self.start_address
      b.END_ADDRESS self.end_address
      b.DRIVER_TIN self.driver_tin
      b.CHEK_DRIVER_TIN (self.check_driver_tin ? 1 : 0)
      b.DRIVER_NAME self.driver_name
      b.TRANSPORT_COAST (self.transportation_cost ? self.transportation_cost : 0)
      b.RECEPTION_INFO self.seller_info
      b.RECEIVER_INFO self.buyer_info
      b.DELIVERY_DATE (self.delivery_date ? self.delivery_date.strftime('%Y-%m-%dT%H:%M:%S') : '')
      b.STATUS self.status
      b.SELER_UN_ID self.seller_id
      b.PAR_ID (self.parent_id ? self.parent_id : '')
      b.CAR_NUMBER self.car_number
      b.BEGIN_DATE (self.start_date ? self.start_date.strftime('%Y-%m-%dT%H:%M:%S') : '')
      b.TRANS_COST_PAYER (self.transportation_cost_payer ? self.transportation_cost_payer : Waybill::TRANSPORTATION_PAID_BY_BUYER)
      b.TRANS_ID self.transport_type_id
      b.TRANS_TXT self.transport_type_name
      b.COMMENT self.comment
    end
  end
end

waybill = Waybill.new
waybill.type = 2
waybill.status = Waybill::STATUS_SAVED
waybill.seller_id = 731937
waybill.buyer_tin = '12345678910'
waybill.check_buyer_tin = true
waybill.buyer_name = 'სატესტო ორგანიზაცია - 2'
waybill.start_address = 'Tbilisi'
waybill.end_address = 'Sokhumi'
waybill.transport_type_id = 1
waybill.driver_name = 'დიმიტრი ყურაშვილი'
waybill.car_number = 'WDW842'
waybill.driver_tin = '02001000490'
waybill.start_date = Time.now

item = WaybillItem.new
item.prod_name = 'კიტრი'
item.unit_id = 99
item.unit_name = 'კგ'
item.quantity = 10
item.price = 10
item.bar_code = '1234'

waybill.items = []
waybill.items << item

resp = client.request 'save_waybill' do |soap|
  #xml = Builder::XmlMarkup.new
  soap.body do |xml|
    xml.ins0 :su, 'dimitri1979'
    xml.ins0 :sp, '123456'
    xml.ins0 :waybill do |b|
      waybill.to_xml b
    end
  end
end
