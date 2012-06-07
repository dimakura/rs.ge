# -*- encoding : utf-8 -*-
require 'singleton'

module RS
  # Unit, which cannot be found in main list.
  UNIT_OTHERS = 99

  class DictionaryRequest < BaseRequest
    include Singleton

    # Returns RS.GE units.
    def units(opts)
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
    def waybill_types(opts)
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

    # Returns name by given TIN number.
    def get_name_from_tin(params)
      validate_presence_of(params, :su, :sp, :tin)
      response = waybill_client.request 'get_name_from_tin' do
        soap.body = params
      end
      response.to_hash[:get_name_from_tin_response][:get_name_from_tin_result]
    end

  end

  class << self
    def dict
      RS::DictionaryRequest.instance
    end
  end
end
