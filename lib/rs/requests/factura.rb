# -*- encoding : utf-8 -*-
require 'singleton'

module RS

  # Factura requests.
  class InvoiceRequest < BaseRequest
    include Singleton

    def create_factura(opts = {})
      # TODO:
    end

    def get_factura(opts = {})
      #validate_presence_of(opts, :id, :user_id :su, :sp)
      #response = waybill_client.request 'get_invoice' do
      #  soap.body = {'user_id' => opts[:user_id], 'invois_id' => opts[:id], 'su' => opts[:su], 'sp' => opts[:sp]}
      #end
      #puts response.to_hash
      # factura = RS::Factura.new
      # wb.init_from_hash(response.to_hash[:get_waybill_response][:get_waybill_result][:waybill])
    end

  end

  class << self
    def fact
      RS::FacturaRequest.instance
    end

    def factura
      RS::FacturaRequest.instance
    end
  end

end
