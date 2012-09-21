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
    def get_waybill(opts)
      validate_presence_of(opts, :id, :su, :sp)
      response = waybill_client.request 'get_waybill' do
        soap.body = {'su' => opts[:su], 'sp' => opts[:sp], 'waybill_id' => opts[:id]}
      end
      wb = RS::Waybill.new
      #puts response.to_hash
      wb.init_from_hash(response.to_hash[:get_waybill_response][:get_waybill_result][:waybill])
    end

    # Activate waybill.
    def activate_waybill(opts)
      validate_presence_of(opts, :id, :su, :sp)
      if opts[:date]
        response = waybill_client.request 'send_waybil_vd' do
          soap.body = { 'su' => opts[:su], 'sp' => opts[:sp], 'begin_date' => format_date(opts[:date]), 'waybill_id' => opts[:id] }
        end
        response.to_hash[:send_waybil_vd_response][:send_waybil_vd_result]
      else
        response = waybill_client.request 'send_waybill' do
          soap.body = { 'su' => opts[:su], 'sp' => opts[:sp], 'waybill_id' => opts[:id] }
        end
        response.to_hash[:send_waybill_response][:send_waybill_result]
      end
    end

    # Close waybill.
    def close_waybill(opts)
      validate_presence_of(opts, :su, :sp, :id)
      if opts[:date]
        response = waybill_client.request 'close_waybill_vd' do
          soap.body = { 'su' => opts[:su], 'sp' => opts[:sp], 'delivery_date' => format_date(opts[:date]), 'waybill_id' => opts[:id] }
        end
        response.to_hash[:close_waybill_vd_response][:close_waybill_vd_result].to_i == 1
      else
        response = waybill_client.request 'close_waybill' do
          soap.body = { 'su' => opts[:su], 'sp' => opts[:sp], 'waybill_id' => opts[:id] }
        end
        response.to_hash[:close_waybill_response][:close_waybill_result].to_i == 1
      end
    end

    # Delete waybill.
    # This operation is permitted only for waybill with RS::Waybill::STATUS_SAVED status.
    def delete_waybill(opts)
      validate_presence_of(opts, :id, :su, :sp)
      response = waybill_client.request 'del_waybill' do |soap|
        soap.body = {'su' => opts[:su], 'sp' => opts[:sp], 'waybill_id' => opts[:id]}
      end
      response.to_hash[:del_waybill_response][:del_waybill_result].to_i == 1
    end

    # Deactivate waybill.
    # This operation is permitted only for waybill with RS::Waybill::STATUS_ACTIVE or RS::Waybill::STATUS_CLOSED statuses.
    def deactivate_waybill(opts)
      validate_presence_of(opts, :id, :su, :sp)
      response = waybill_client.request 'ref_waybill' do |soap|
        soap.body = {'su' => opts[:su], 'sp' => opts[:sp], 'waybill_id' => opts[:id]}
      end
      response.to_hash[:ref_waybill_response][:ref_waybill_result].to_i == 1
    end

    # Save this waybill as invoice, related to this waybill.
    # Returns invoice ID (or `nil` if the save operation was unsuccessfull).
    def save_invoice(opts)
      validate_presence_of(opts, :id, :su, :sp)
      response = waybill_client.request 'save_invoice' do |soap|
        soap.body = {'su' => opts[:su], 'sp' => opts[:sp], 'waybill_id' => opts[:id], 'in_inv_id' => (opts[:invoice_id] || 0)}
      end
      resp = response.to_hash[:save_invoice_response][:save_invoice_result].to_i
      if resp == 1
        response.to_hash[:save_invoice_response][:out_inv_id].to_i
      else
        self.last_error_code = resp
        nil
      end
    end

  end

  class << self
    def wb
      RS::WaybillRequest.instance
    end

    def waybill
      RS::WaybillRequest.instance
    end
  end

end
