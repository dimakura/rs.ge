# -*- encoding : utf-8 -*-
require 'singleton'

module RS

  # Factura requests.
  class InvoiceRequest < BaseRequest
    include Singleton

    def create_factura(opts = {})
      validate_presence_of(opts, :user_id, :payer_id, :su, :sp, :date)
      response = invoice_client.request 'save_invoice' do
        soap.body = {
          'user_id' => opts[:user_id],
          'invois_id' => 0, 'operation_date' => format_date(opts[:date]),
          'seller_un_id' => opts[:payer_id],
          'buyer_un_id' => 0,
          'overhead_no' => '', 'overhead_dt' => format_date(Time.now), # not USED actually
          'b_s_user_id' => 0,
          'su' => opts[:su], 'sp' => opts[:sp]}
      end.to_hash
      if response[:save_invoice_response][:save_invoice_result]
        response[:save_invoice_response][:invois_id].to_i
      end
    end

    def get_factura(opts = {})
      validate_presence_of(opts, :id, :user_id, :su, :sp)
      response = invoice_client.request 'get_invoice' do
        soap.body = {'user_id' => opts[:user_id], 'invois_id' => opts[:id], 'su' => opts[:su], 'sp' => opts[:sp]}
      end.to_hash
      if response[:get_invoice_response][:get_invoice_result]
        hash = response[:get_invoice_response]
        factura = RS::Factura.new
        factura.id = opts[:id]
        factura.index = hash[:f_series]
        factura.number = hash[:f_number].to_i unless hash[:f_number].to_i == -1
        factura.operation_date = hash[:operation_dt]
        factura.registration_date = hash[:reg_dt]
        factura.seller_id = hash[:seller_un_id].to_i unless hash[:seller_un_id] == -1
        factura.buyer_id = hash[:buyer_un_id].to_i unless hash[:buyer_un_id] == -1
        factura.status = hash[:status].to_i
        factura.waybill_number = hash[:overhead_no]
        factura.waybill_date = hash[:overhead_dt]
        factura.correction_of hash[:k_id].to_i unless hash[:k_id].to_i == -1
        factura
      end
    end

  end

  class << self
    def fact
      RS::InvoiceRequest.instance
    end

    def factura
      RS::InvoiceRequest.instance
    end
  end

end
