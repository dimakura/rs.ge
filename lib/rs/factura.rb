# -*- encoding : utf-8 -*-
module RS
  class Factura < RS::Initializable
    attr_accessor :id, :date
    attr_accessor :seller_id, :buyer_id
  end

  class FacturaItem < RS::Initializable
    attr_accessor :id, :factura, :good, :unit
    attr_accessor :amount, :quantity, :vat, :excise_amount, :excise_code
  end

  def save_factura(factura, opts = {})
    validate_presence_of(opts, :user_id, :su, :sp)
    if opts[:buyer_tin].present?
      params = { su: opts[:su], sp: opts[:sp], tin: opts[:buyer_tin], user_id: opts[:user_id] }
      factura.buyer_id = RS.get_oranizaton_info_from_tin(params)[:id]
    end
    raise 'define seller' if factura.seller_id.blank?
    raise 'define buyer' if factura.buyer_id.blank?
    response = invoice_client.call(:save_invoice, message: {
      'user_id' => opts[:user_id], 'invois_id' => (factura.id || 0), 'operation_date' => (factura.date || Time.now),
      'seller_un_id' => factura.seller_id, 'buyer_un_id' => factura.buyer_id,
      'overhead_no' => '', 'overhead_dt' => format_date(Time.now), # those two parameters are not used actually!
      'su' => opts[:su], 'sp' => opts[:sp],
    }).to_hash
    if response[:save_invoice_response][:save_invoice_result]
      factura.id = response[:save_invoice_response][:invois_id].to_i
      true
    else
      false
    end
  end

  def save_factura_item(factura_item, opts = {})
    factura = factura_item.factura
    validate_presence_of(opts, :user_id, :su, :sp)
    raise 'factura not saved' if (factura.id.blank? or factura.id == 0)
    response = invoice_client.call(:save_invoice_desc, message: {
      'user_id' => opts[:user_id], 'id' => (factura_item.id || 0), 'su' => opts[:su], 'sp' => opts[:sp],
      'invois_id' => factura.id, 'goods' => factura_item.good, 'g_unit' => factura_item.unit, 'g_number' => factura_item.quantity,
      'full_amount' => factura_item.amount, 'drg_amount' => factura_item.vat,
      'aqcizi_amount' => (factura_item.excise_amount || 0), 'akciz_id' => (factura_item.excise_code || 0)
    }).to_hash
    if response[:save_invoice_desc_response][:save_invoice_desc_result]
      factura_item.id = response[:save_invoice_desc_response][:id].to_i
      true
    else
      false
    end
  end

  module_function :save_factura
  module_function :save_factura_item
end
