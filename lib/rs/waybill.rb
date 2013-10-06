# -*- encoding : utf-8 -*-
module RS
  class Waybill < RS::Initializable
    SAVED   =  0
    ACTIVE  =  1
    CLOSED  =  2
    DELETED  = -1
    DEACTIVATED = -2

    INNER = 1
    TRANS = 2
    WITHOUT_TRANS = 3
    DISTR = 4
    RETRN = 5
    SUBWB = 6

    WAYBILL_TYPES = {
      INNER => 'შიდა გადაზიდვა',
      TRANS => 'ტრანსპორტირებით',
      WITHOUT_TRANS => 'ტრანსპორტირების გარეშე',
      DISTR => 'დისტრიბუცია',
      RETRN => 'უკან დაბრუნება',
      SUBWB => 'ქვე-ზედნადები'
    }

    TRANSP_PAID_BY_BUYER  = 1
    TRANSP_PAID_BY_SELLER = 2

    TRANS_VEHICLE = 1
    TRANS_RAILWAY = 2
    TRANS_AIR     = 3
    TRANS_OTHER   = 4
    TRANS_VEHICLE_FRGN = 6

    TRANSPORT_TYPES = {
      TRANS_VEHICLE => 'საავტომობილო',
      TRANS_RAILWAY => 'სარკინიგზო',
      TRANS_AIR     => 'საავიაციო',
      TRANS_OTHER   => 'სხვა',
      TRANS_VEHICLE_FRGN => 'საავტომობილო - უცხო ქვეყნის'
    }

    attr_accessor :id, :parent_id, :number, :type, :status
    attr_accessor :seller_id, :seller_tin, :seller_name
    attr_accessor :buyer_tin, :check_buyer_tin, :buyer_name
    attr_accessor :driver_tin, :check_driver_tin, :driver_name
    attr_accessor :start_address, :end_address
    attr_accessor :create_date, :activation_date, :begin_date, :delivery_date, :close_date
    attr_accessor :transport_cost, :transport_cost_payer, :vehicle
    attr_accessor :transport_type, :transport_name
    attr_accessor :comment, :seller_info, :buyer_info
    attr_accessor :amount, :su_id
    attr_accessor :items
    attr_accessor :confirmed, :confirmation_date
    attr_accessor :invoice_id

    def self.extract(data)
      parent_id = data[:par_id].to_i == 0 ? nil : data[:par_id].to_i
      Waybill.new(
        id: data[:id].to_i, type: data[:type].to_i, status: data[:status].to_i,
        seller_id: data[:seler_un_id].to_i, seller_name: data[:seller_name], seller_tin: data[:seller_tin],
        parent_id: parent_id, number: data[:waybill_number],
        buyer_tin: data[:buyer_tin], check_buyer_tin: data[:chek_buyer_tin].to_i == 1, buyer_name: data[:buyer_name],
        driver_tin: data[:driver_tin], check_driver_tin: data[:chek_driver_tin].to_i == 1, driver_name: data[:driver_name],
        start_address: data[:start_address], end_address: data[:end_address],
        create_date: data[:create_date], delivery_date: data[:delivery_date],
        activation_date: data[:activate_date], close_date: data[:close_date],
        begin_date: data[:begin_date],
        transport_cost: data[:transport_coast].to_f, amount: data[:full_amount].to_f,
        transport_cost_payer: data[:tran_cost_payer].to_i,
        transport_type: data[:trans_id].to_i, transport_name: data[:trans_txt],
        vehicle: data[:car_number],
        su_id: data[:s_user_id].to_i,
        comment: data[:comment], seller_info: data[:reception_info], buyer_info: data[:receiver_info],
        confirmed: data[:is_confirmed].to_i == 1, confirmation_date: data[:confirmation_date], 
        invoice_id: (data[:invoice_id].present? ? data[:invoice_id].to_i : nil),
        # items: WaybillItem.extract(data[:goods_list][:goods]),
      )
    end
  end

  class WaybillItem < RS::Initializable
    attr_accessor :id, :code, :name, :status
    attr_accessor :unit_id, :unit_name
    attr_accessor :quantity, :quantity_ext, :price, :amount
    attr_accessor :excise_id, :vat_type
  end

  def get_waybill(opts = {})
    validate_presence_of(opts, :id, :su, :sp)
    response = waybill_client.call(:get_waybill, message: {'su' => opts[:su], 'sp' => opts[:sp], 'waybill_id' => opts[:id] }).to_hash
    # puts response[:get_waybill_response][:get_waybill_result]
    Waybill.extract(response[:get_waybill_response][:get_waybill_result][:waybill])
  end

  module_function :get_waybill
end
