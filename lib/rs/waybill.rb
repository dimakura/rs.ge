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
    attr_accessor :confirmed, :confirmation_date, :canceled, :corrected
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
        vehicle: data[:car_number], su_id: data[:s_user_id].to_i,
        comment: data[:comment], seller_info: data[:reception_info], buyer_info: data[:receiver_info],
        confirmed: data[:is_confirmed].to_i == 1, confirmation_date: data[:confirmation_date], 
        canceled: data[:is_confirmed].to_i == -1, corrected: data[:corrected].to_i == 1,
        invoice_id: (data[:invoice_id].present? ? data[:invoice_id].to_i : nil),
        items: (WaybillItem.extract_items(data[:goods_list][:goods]) if data[:goods_list].present?),
      )
    end
  end

  class WaybillItem < RS::Initializable
    attr_accessor :id, :code, :name, :status
    attr_accessor :unit_id, :unit_name
    attr_accessor :quantity, :price, :amount
    attr_accessor :excise_id, :vat_type

    def self.extract(data)
      WaybillItem.new(id: data[:id].to_i, code: data[:bar_code], name: data[:w_name], status: data[:status].to_i,
        unit_id: data[:unit_id].to_i, unit_name: data[:unit_txt],
        quantity: data[:quantity].to_f, price: data[:price].to_f, amount: data[:amount].to_f,
        excise_id: (data[:a_id] == '0' ? nil : data[:a_id].to_i), vat_type: data[:vat_type].to_i)
    end

    def self.extract_items(data)
      items = []
      if data.is_a?(Array)
        data.each { |single| items << WaybillItem.extract(single)  }
      else
        items << WaybillItem.extract(data)
      end
      items
    end
  end

  def get_waybill(opts = {})
    validate_presence_of(opts, :id, :su, :sp)
    response = waybill_client.call(:get_waybill, message: {'su' => opts[:su], 'sp' => opts[:sp], 'waybill_id' => opts[:id] }).to_hash
    Waybill.extract(response[:get_waybill_response][:get_waybill_result][:waybill])
  end

  def get_waybills(opts = {})
    validate_presence_of(opts, :su, :sp)
    message = { 'su' => opts[:su], 'sp' => opts[:sp] }
    waybill_search_params(opts, message)
    response = waybill_client.call(:get_waybills, message: message).to_hash
    waybills = []
    waybill_data = response[:get_waybills_response][:get_waybills_result][:waybill_list][:waybill]
    if waybill_data.is_a?(Array)
      waybill_data.each { |data| waybills << Waybill.extract(data) }
    else
      waybills << Waybill.extract(waybill_data)
    end
    waybills
  end

  # def get_buyer_waybills(opts = {})    
  # end

  # fills search parameters opts -> message
  private

  def waybill_search_params(opts, message)
    message['itypes'] = opts[:types].join(',') if opts[:types].present?
    message['buyer_tin'] = opts[:buyer_tin] if opts[:buyer_tin].present?
    message['statuses'] = opts[:statuses].join(',') if opts[:statuses].present?
    message['car_number'] = opts[:vehicle] if opts[:vehicle].present?
    message['begin_date_s'] = opts[:begin_date_1] if opts[:begin_date_1].present?
    message['begin_date_e'] = opts[:begin_date_2] if opts[:begin_date_2].present?
    message['create_date_s'] = opts[:create_date_1] if opts[:create_date_1].present?
    message['create_date_e'] = opts[:create_date_2] if opts[:create_date_2].present?
    message['driver_tin'] = opts[:driver_tin] if opts[:driver_tin].present?
    message['delivery_date_s'] = opts[:delivery_date_1] if opts[:delivery_date_1].present?
    message['delivery_date_e'] = opts[:delivery_date_2] if opts[:delivery_date_2].present?
    message['full_amount'] = opts[:amount] if opts[:amount].present?
    message['waybill_number'] = opts[:number] if opts[:number].present?
    message['close_date_s'] = opts[:close_date_1] if opts[:close_date_1]
    message['close_date_e'] = opts[:close_date_2] if opts[:close_date_2]
  end

  module_function :waybill_search_params
  module_function :get_waybill
  module_function :get_waybills
end
