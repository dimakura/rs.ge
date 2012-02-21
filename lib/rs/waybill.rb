# -*- encoding : utf-8 -*-

module RS

  # ეს არის ზედნადების ხაზი საქონლისთვის.
  class WaybillItem
    attr_accessor :id, :prod_name, :unit_id, :unit_name, :quantity, :price, :bar_code, :excise_id

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
    TRANSPORTATION_PAID_BY_BUYER  = 1
    TRANSPORTATION_PAID_BY_SELLER = 2
    STATUS_START  = 0
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
    attr_accessor :error_code

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

  # ზედნადების შენახვის მეთოდი
  #
  # გადაეცემა:
  # waybill -- ზედნადები
  # params -- პარამეტრები
  #
  # პარამეტრების შემდეგი მნიშვნელობებია დასაშვები:
  # su -- სერვისის მომხმარებლის სახელი
  # sp -- სერვისის მომხმარებლის პაროლი
  #
  # ინახავს ამ ზედნადებს და განაახლებს მის მონაცემებს.
  def save_waybill(waybill, params)
    RS.validate_presence_of(params, 'su', 'sp')
    client = RS.waybill_service
    response = client.request 'save_waybill' do |soap|
      soap.body do |xml|
        xml.ins0 :su, params['su']
        xml.ins0 :sp, params['sp']
        xml.ins0 :waybill do |b|
          waybill.to_xml b
        end
      end
    end
    hash_results = response.to_hash[:save_waybill_response][:save_waybill_result][:result]
    if hash_results[:status].to_i == 0
      waybill.id = hash_results[:id].to_i
      waybill.error_code = 0
      items_hash = hash_results[:goods_list][:goods]
      items_hash = [items_hash] if items_hash.instance_of? Hash
      (0..items_hash.size-1).each do |i|
        waybill.items[i].id = items_hash[i][:id].to_i
        #waybill.items[i].error_code = items_hash[i][:error].to_i
      end
    else
      waybill.error_code = hash_results[:status].to_i
    end
  end

end
