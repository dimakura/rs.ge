# -*- encoding : utf-8 -*-
require 'singleton'

module RS
  class DictionaryRequest < BaseRequest
    include Singleton

    def units(opts = {})
      validate_presence_of(opts, :su, :sp)
      response = waybill_client.request 'get_waybill_units' do
        soap.body = { 'su' => opts[:su], 'sp' => opts[:sp] }
      end
      extract_units_from_response(response)
    end

    private

    def extract_units_from_response(response)
      units = []
      units_hash = response.to_hash[:get_waybill_units_response][:get_waybill_units_result][:waybill_units][:waybill_unit]
      units_hash.each do |hash|
        unit = WaybillUnit.new
        unit.id = hash[:id].to_i
        unit.name = hash[:name]
        units << unit
      end
      units
    end

  end

  class << self
    def dict
      RS::DictionaryRequest.instance
    end
  end
end
