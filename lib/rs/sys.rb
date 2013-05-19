# -*- encoding : utf-8 -*-
module RS
  def what_is_my_ip
    waybill_client.call(:what_is_my_ip).body.to_hash[:what_is_my_ip_response][:what_is_my_ip_result]
  end

  module_function :what_is_my_ip
end
