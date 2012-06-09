# -*- encoding : utf-8 -*-
require 'singleton'

module RS
  
  class WaybillRequest < BaseRequest
    include Singleton

    # Save given waybill.
    def save_waybill(waybill, opts = {})
      validate_presence_of(opts, :su, :sp)
      response = waybill_client.request 'save_waybill' do |soap|
        soap.body do |xml|
          xml.ins0 :su, opts[:su]
          xml.ins0 :sp, opts[:sp]
          xml.ins0 :waybill do |b|
            waybill.to_xml b
          end
        end
      end
      hash_results = response.to_hash[:save_waybill_response][:save_waybill_result][:result]
      if hash_results[:status].to_i == 0
        waybill.id = hash_results[:id].to_i == 0 ? nil : hash_results[:id].to_i
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

    # Get saved waybill.
    def get_waybill(opts = {})
      validate_presence_of(opts, :id, :su, :sp)
      response = waybill_client.request 'get_waybill' do
        soap.body = {'su' => opts[:su], 'sp' => opts[:sp], 'waybill_id' => opts[:id]}
      end
      wb = RS::Waybill.new
      #puts response.to_hash
      wb.init_from_hash(response.to_hash[:get_waybill_response][:get_waybill_result][:waybill])
    end

  end

  class << self
    def wb
      RS::WaybillRequest.instance
    end
  end

end
