# -*- encoding : utf-8 -*-
require 'singleton'

module RS

  # Factura requests.
  class InvoiceRequest < BaseRequest
    include Singleton

    def save_factura(factura, opts = {})
      validate_presence_of(opts, :user_id, :su, :sp)
      response = invoice_client.request 'save_invoice' do
        soap.body = {
          'user_id' => opts[:user_id],
          'invois_id' => factura.id || 0,
          'operation_date' => format_date(factura.operation_date || Time.now),
          'seller_un_id' => factura.seller_id || 0,
          'buyer_un_id' => factura.buyer_id || 0,
          'overhead_no' => '', 'overhead_dt' => format_date(Time.now), # this 2 parameters are not USED actually!!
          'b_s_user_id' => factura.buyer_su_id || 0,
          'su' => opts[:su], 'sp' => opts[:sp]}
      end.to_hash
      resp = response[:save_invoice_response][:save_invoice_result]
      factura.id = response[:save_invoice_response][:invois_id].to_i if resp
      resp
    end

    def save_factura_item(item, opts = {})
      validate_presence_of(opts, :user_id, :su, :sp)
      response = invoice_client.request 'save_invoice_desc' do
        soap.body = {
          'user_id' => opts[:user_id],
          'id' => item.id || 0,
          'su' => opts[:su], 'sp' => opts[:sp],
          'invois_id' => item.factura_id,
          'goods' => item.name,
          'g_unit' => item.unit,
          'g_number' => item.quantity || 1,
          'full_amount' => item.total || 0,
          'drg_amount' => item.vat || 0,
          'aqcizi_amount' => item.excise || 0,
          'akciz_id' => item.excise_id || 0
        }
      end.to_hash
      resp = response[:save_invoice_desc_response][:save_invoice_desc_result]
      item.id = response[:save_invoice_desc_response][:id].to_i if resp
      resp
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
        factura.correction_of = hash[:k_id].to_i unless hash[:k_id].to_i == -1
        factura.correction_type = hash[:k_type].to_i unless hash[:k_type].to_i == -1
        factura
      end
    end

    def get_factura_items(opts = {})
      validate_presence_of(opts, :id, :user_id, :su, :sp)
      response = invoice_client.request 'get_invoice_desc' do
        soap.body = { 'user_id' => opts[:user_id], 'invois_id' => opts[:id], 'su' => opts[:su], 'sp' => opts[:sp] }
      end.to_hash
      h_items = response[:get_invoice_desc_response][:get_invoice_desc_result][:diffgram][:document_element][:invoices_descs]
      items = []
      if h_items.kind_of?(Array)
        h_items.each do |item|          
          items << factura_item_from_hash(item)
        end
      elsif h_items.kind_of?(Hash)
        items << factura_item_from_hash(h_items)
      end
      items
    end

    def delete_factura_item(opts = {})
      validate_presence_of(opts, :id, :factura_id, :su, :sp, :user_id)
      response = invoice_client.request 'delete_invoice_desc' do
        soap.body = { 'user_id' => opts[:user_id], 'id' => opts[:id], 'inv_id' => opts[:factura_id], 'su' => opts[:su], 'sp' => opts[:sp] }
      end.to_hash
      response[:delete_invoice_desc_response][:delete_invoice_desc_result]
    end

    def send_factura(opts = {})
      # XXX: check status before send
      change_factura_status(RS::Factura::STATUS_SENT, opts)
    end

    private

    def factura_item_from_hash(hash)
      RS::FacturaItem.new(id: hash[:id].to_i, factura_id: hash[:inv_id].to_i, name: hash[:goods], unit: hash[:g_unit],
        quantity: hash[:g_number].to_f, total: hash[:full_amount].to_f, vat: hash[:drg_amount].to_f,
        excise: hash[:aqcizi_amount].to_f, excise_id: hash[:akcis_id].to_i)
    end

    def change_factura_status(status, opts)
      validate_presence_of(opts, :user_id, :id, :su, :sp)
      response = invoice_client.request 'change_invoice_status' do
        soap.body = { 'user_id' => opts[:user_id], 'inv_id' => opts[:id], 'status' => status, 'su' => opts[:su], 'sp' => opts[:sp] }
      end
      response[:change_invoice_status_response][:change_invoice_status_result]
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
