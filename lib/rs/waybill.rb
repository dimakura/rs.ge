# -*- encoding : utf-8 -*-

module RS

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
    TRANSPORTATION_PAID_BY_BUYER  = 1
    TRANSPORTATION_PAID_BY_SELLER = 2
    STATUS_START  = 0
    STATUS_ACTIVE = 1
    # XXX ???
    #STATUS_COMPLETED = -1
    #STATUS_CANCELED  = -2
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

  # TODO: save waybill

end
