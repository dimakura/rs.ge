# -*- encoding : utf-8 -*-
module RS
  def get_oranizaton_info_from_tin(opts)
    validate_presence_of(opts, :su, :sp, :tin, :user_id)
    message = { 'user_id' => opts[:user_id], 'tin' => opts[:tin], 'su' => opts[:su], 'sp' => opts[:sp] }
    # puts message
    response = invoice_client.call(:get_un_id_from_tin, message: message).to_hash
    id = response[:get_un_id_from_tin_response][:get_un_id_from_tin_result]
    name = response[:get_un_id_from_tin_response][:name]
    { id: id, name: name }
  end

  def is_vat_payer(opts)
    validate_presence_of(opts, :su, :sp, :payer_id)
    message = { 'su' => opts[:su], 'sp' => opts[:sp], 'un_id' => opts[:payer_id] }
    response = waybill_client.call(:is_vat_payer, message: message).to_hash
    response[:is_vat_payer_response][:is_vat_payer_result]
  end

  def get_name_from_tin(opts)
    validate_presence_of(opts, :su, :sp, :tin)
    response = waybill_client.call :get_name_from_tin, message: { su: opts[:su], sp: opts[:sp], tin: opts[:tin] }
    response.to_hash[:get_name_from_tin_response][:get_name_from_tin_result]
  end

  module_function :get_oranizaton_info_from_tin
  module_function :is_vat_payer
  module_function :get_name_from_tin
end
