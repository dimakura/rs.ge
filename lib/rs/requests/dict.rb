# -*- encoding : utf-8 -*-
require 'singleton'

module RS
  # Unit, which cannot be found in main list.
  UNIT_OTHERS = 99

  WAYBILL_TYPE_INNER = 1
  WAYBILL_TYPE_TRANS = 2
  WAYBILL_TYPE_WITHOUT_TRANS = 3
  WAYBILL_TYPE_DISTR = 4
  WAYBILL_TYPE_RETRN = 5
  WAYBILL_TYPE_SUBWB = 6

  WAYBILL_TYPES = {
    WAYBILL_TYPE_INNER => 'შიდა გადაზიდვა',
    WAYBILL_TYPE_TRANS => 'ტრანსპორტირებით',
    WAYBILL_TYPE_WITHOUT_TRANS => 'ტრანსპორტირების გარეშე',
    WAYBILL_TYPE_DISTR => 'დისტრიბუცია',
    WAYBILL_TYPE_RETRN => 'უკან დაბრუნება',
    WAYBILL_TYPE_SUBWB => 'ქვე-ზედნადები'
  }

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

  class DictionaryRequest < BaseRequest

    include Singleton

    # Returns RS.GE units.
    def units(opts = {})
      validate_presence_of(opts, :su, :sp)
      response = waybill_client.request 'get_waybill_units' do
        soap.body = { 'su' => opts[:su], 'sp' => opts[:sp] }
      end
      resp = response.to_hash[:get_waybill_units_response][:get_waybill_units_result][:waybill_units][:waybill_unit]
      units = {}
      resp.each do |unit|
        units[unit[:id].to_i] = unit[:name]
      end
      units
    end

    # Returns RS.GE waybill types.
    def waybill_types(opts = {})
      validate_presence_of(opts, :su, :sp)
      response = waybill_client.request 'get_waybill_types' do
        soap.body = { 'su' => opts[:su], 'sp' => opts[:sp] }
      end
      resp = response.to_hash[:get_waybill_types_response][:get_waybill_types_result][:waybill_types][:waybill_type]
      types = {}
      resp.each do |type|
        types[type[:id].to_i] = type[:name]
      end
      types
    end

    # Returns RS.GE transport types.
    def transport_types(opts = {})
      validate_presence_of(opts, :su, :sp)
      response = waybill_client.request 'get_trans_types' do
        soap.body = { 'su' => opts[:su], 'sp' => opts[:sp] }
      end
      resp = response.to_hash[:get_trans_types_response][:get_trans_types_result][:transport_types][:transport_type]
      types = {}
      resp.each do |type|
        types[type[:id].to_i] = type[:name]
      end
      types
    end

    # Returns name by given TIN number.
    def get_name_from_tin(params = {})
      validate_presence_of(params, :su, :sp, :tin)
      response = waybill_client.request 'get_name_from_tin' do
        soap.body = params
      end
      response.to_hash[:get_name_from_tin_response][:get_name_from_tin_result]
    end

    def payer_info(params = {})
      validate_presence_of(params, :su, :sp)
      response = invoice_client.request 'chek' do
        soap.body = {'su' => params[:su], 'sp' => params[:sp]}
      end
      response
    end

    # Checks whether given argument is a correct personal TIN.
    def personal_tin?(tin)
      tin =~ /^[0-9]{11}$/
    end

    # Checks whether given argument is a correct corporate TIN.
    def corporate_tin?(tin)
      tin =~ /^[0-9]{9}$/
    end

  end

  class << self
    def dict
      RS::DictionaryRequest.instance
    end

    def dictionary
      RS::DictionaryRequest.instance
    end
  end

end
