# -*- encoding : utf-8 -*-
module RS
  def get_name_from_tin(opts)
    validate_presence_of(opts, :su, :sp, :tin)
    response = waybill_client.call :get_name_from_tin, message: { su: opts[:su], sp: opts[:sp], tin: opts[:tin] }
    response.to_hash[:get_name_from_tin_response][:get_name_from_tin_result]
  end

  module_function :get_name_from_tin
end
