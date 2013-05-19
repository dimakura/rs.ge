# -*- encoding : utf-8 -*-
module RS
  def get_oranizaton_info_from_tin(opts)
    validate_presence_of(opts, :su, :sp, :tin, :user_id)

puts opts

    response = invoice_client.call(:get_un_id_from_tin, message: { user_id: opts[:user_id], tin: opts[:tin], su: opts[:su], sp: opts[:sp] }).to_hash

puts response

    id = response[:get_un_id_from_tin_response][:get_un_id_from_tin_result]
    name = response[:get_un_id_from_tin_response][:name]
    { id: id, name: name }
  end

  def get_name_from_tin(opts)
    validate_presence_of(opts, :su, :sp, :tin)
    response = waybill_client.call :get_name_from_tin, message: { su: opts[:su], sp: opts[:sp], tin: opts[:tin] }
    response.to_hash[:get_name_from_tin_response][:get_name_from_tin_result]
  end

  module_function :get_oranizaton_info_from_tin
  module_function :get_name_from_tin
end
