# -*- encoding : utf-8 -*-
module RS
  class Factura < RS::Initializable
    ## == Factura statuses ==

    # Newly created factura.
    NEW = 0
    # Factura, which was sent for review.
    SENT = 1
    # Factura, which was sent and confirmed.
    CONFIRMED = 2
    # Factura is "corrected" by another factura.
    CORRECTED = 3
    # New factura, which corrects an old factura.
    CORRECTION_NEW = 4
    # Correction factura, which is sent to buyer.
    CORRECTION_SENT = 5
    # Correction factura, which is confirmed.
    CORRECTION_CONFIRMED = 8
    # Canceled factura.
    CANCELED = 6
    # Factura which was confirmed and canceled afterwards.
    CANCELED_CONFIRMED = 7

    ## == Factura correction types ==

    # Gathering operation was canceled.
    CANCELD_GATHERING_OPERATION = 1
    # Gathering operation was changed.
    CHANGED_GATHERING_OPERATION = 2
    # Prices changed or any other reason.
    CHANGED_PRICES = 3
    # Some goods are returned.
    RETURNED_GOODS = 4

    attr_accessor :id, :date, :register_date, :status
    attr_accessor :seller_id, :buyer_id
    attr_accessor :seria, :number

    # ID of the factura which was corrected by this factura.
    attr_accessor :corrected_id
    attr_accessor :correction_type

    def new?; [ NEW, CORRECTION_NEW ].include?(self.status) end
    def sent?; [ SENT, CORRECTION_SENT ].include?(self.status) end
    def confirmed?; [ CONFIRMED, CORRECTION_CONFIRMED ].include?(self.status) end
    def canceled?; [ CANCELED, CANCELED_CONFIRMED ].include?(self.status) end
    def corrected?; [ CORRECTED ].include?(self.status) end

    def self.extract(id, data)
      Factura.new(id: id, date: data[:operation_dt], register_date: data[:reg_dt],
        seller_id: data[:seller_un_id].to_i, buyer_id: data[:buyer_un_id].to_i,
        status: data[:status].to_i,
        corrected_id: (data[:k_id].to_i < 0 ? nil : data[:k_id].to_i),
        correction_type: (data[:k_type].to_i < 0 ? nil : data[:k_type].to_i),
        seria: data[:f_series], number: (data[:f_number].to_i < 0 ? nil : data[:f_number].to_i))
    end
  end

  class FacturaItem < RS::Initializable
    attr_accessor :id, :factura, :good, :unit
    attr_accessor :amount, :quantity, :vat, :excise_amount, :excise_code

    def self.extract(data)
      items = []
      if data.is_a?(Array) then data.each { |x| items << extract_single(x) }
      else items << extract_single(data) end
      items
    end

    def self.extract_single(data)
      # :id=>"226635210",
      # :inv_id=>"33483243",
      # :goods=>"potato",
      # :g_unit=>"kg",
      # :g_number=>"10",
      # :full_amount=>"100",
      # :drg_amount=>"15.25",
      # :aqcizi_amount=>"0",
      # :akcis_id=>"0",
      FacturaItem.new(id: data[:id].to_i, good: data[:goods], unit: data[:g_unit], quantity: data[:g_number].to_f,
        amount: data[:full_amount].to_f, vat: data[:drg_amount].to_f, excise_amount: data[:aqcizi_amount].to_f,
        excise_code: ( data[:akcis_id].to_i == 0 ? nil : data[:akcis_id].to_i )
      )
    end
  end

  def save_factura(factura, opts = {})
    validate_presence_of(opts, :user_id, :su, :sp)
    if opts[:seller_tin].present? and factura.seller_id.blank?
      factura.seller_id = RS.get_oranizaton_info_from_tin({ su: opts[:su], sp: opts[:sp], tin: opts[:seller_tin], user_id: opts[:user_id] })[:id]
    end
    if opts[:buyer_tin].present? and factura.buyer_id.blank?
      factura.buyer_id = RS.get_oranizaton_info_from_tin({ su: opts[:su], sp: opts[:sp], tin: opts[:buyer_tin], user_id: opts[:user_id] })[:id]
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

  def delete_factura_item(opts = {})
    validate_presence_of(opts, :user_id, :su, :sp, :factura_id, :id)
    response = invoice_client.call(:delete_invoice_desc, message: {
      'user_id' => opts[:user_id], 'id' => opts[:id], 'inv_id' => opts[:factura_id],
      'su' => opts[:su], 'sp' => opts[:sp],
    }).to_hash
    response[:delete_invoice_desc_response][:delete_invoice_desc_result]
  end

  def get_factura_by_id(opts = {})
    validate_presence_of(opts, :user_id, :su, :sp, :id)
    response = invoice_client.call(:get_invoice, message: {
      'user_id' => opts[:user_id], 'invois_id' => opts[:id],
      'su' => opts[:su], 'sp' => opts[:sp]
    }).to_hash
    Factura.extract(opts[:id], response[:get_invoice_response]) if response[:get_invoice_response][:get_invoice_result]
  end

  def get_factura_items(opts = {})
    validate_presence_of(opts, :user_id, :su, :sp, :id)
    response = invoice_client.call(:get_invoice_desc, message: {
      'user_id' => opts[:user_id], 'invois_id' => opts[:id],
      'su' => opts[:su], 'sp' => opts[:sp]
    }).to_hash
    result = response[:get_invoice_desc_response][:get_invoice_desc_result]
    if result[:diffgram][:document_element]
      FacturaItem.extract(result[:diffgram][:document_element][:invoices_descs])
    else
      []
    end
  end

  def send_factura()
    # bool change_invoice_status(int user_id, int inv_id, int status, string su, string sp)
  end

  module_function :save_factura
  module_function :save_factura_item
  module_function :delete_factura_item
  module_function :get_factura_by_id
  module_function :get_factura_items
end
