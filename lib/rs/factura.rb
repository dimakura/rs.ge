# -*- encoding : utf-8 -*-
module RS
  class Factura < RS::Initializable
    attr_accessor :id, :date
    attr_accessor :seller_id, :buyer_id
  end

  def create_factura(factura, opts = {})
    if opts[:buyer_tin].present?
      # opts[:buyer_id] = RS.get_oranizaton_info_from_tin(su: opts[:su], opts[:sp], tin: opts[:buyer_tin], user_id: user_id)[:id]
    end
    if opts[:user_id].blank?
      # opts[:user_id] = RS.check_user(su: opts[:su], opts[:sp])[:user]
    end
    validate_presence_of(opts, :user_id, :su, :sp, :buyer_id, :seller_id)
    response = invoice_client.call(:save_invoice, message: {
      'user_id' => opts[:user_id], 'invois_id' => (factura.id || 0), 'operation_date' => (factura.date || Time.now),
      'seller_un_id' => factura.seller_id, 'buyer_un_id' => factura.buyer_id,
      'overhead_no' => nil, 'overhead_dt' => nil, 'b_s_user_id' => nil,
      'su' => opts[:su], 'sp' => opts[:sp],
    }).to_hash
    # if response[:chek_service_user_response][:chek_service_user_result]
    #   payer_id = response[:chek_service_user_response][:un_id]
    #   user_id  = response[:chek_service_user_response][:s_user_id]
    #   { payer: payer_id.to_i, user: user_id.to_i }
    # end
    # bool save_invoice(int user_id, ref int invois_id, DateTime operation_date, int 
    #   seller_un_id, int buyer_un_id, string overhead_no, DateTime overhead_dt, int
    #   b_s_user_id, string su, string sp
    # )
  end

  module_function :create_factura
end
