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
      wb.init_from_hash(response.to_hash[:get_waybill_response][:get_waybill_result][:waybill])
    end

    # Get waybills (seller's point of view).
    def get_waybills(opts = {})
      validate_presence_of(opts, :su, :sp)
      message = { 'su' => opts[:su], 'sp' => opts[:sp] }
      waybill_search_params(opts, message)
      response = waybill_client.request 'get_waybills' do
        soap.body = message
      end
      waybill_data = response.to_hash[:get_waybills_response][:get_waybills_result][:waybill_list][:waybill]
      extract_waybills(waybill_data)
    end

    # Get waybills (buyer's point of view).
    def get_buyer_waybills(opts = {})
      validate_presence_of(opts, :su, :sp)
      message = { 'su' => opts[:su], 'sp' => opts[:sp] }
      waybill_search_params(opts, message)
      response = waybill_client.request 'get_buyer_waybills' do
        soap.body = message
      end
      waybill_data = response.to_hash[:get_buyer_waybills_response][:get_buyer_waybills_result][:waybill_list][:waybill]
      extract_waybills(waybill_data)
    end

    def extract_waybills(waybill_data)
      waybills = []
      if waybill_data.is_a?(Array)
        waybill_data.each do |data|
          wb = RS::Waybill.new
          wb.init_from_hash(data)
          waybills << wb
        end
      elsif waybill_data.is_a?(Hash)
        wb = RS::Waybill.new
        wb.init_from_hash(waybill_data)
        waybills << wb
      end
      waybills
    end

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
