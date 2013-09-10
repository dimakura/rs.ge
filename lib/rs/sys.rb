# -*- encoding : utf-8 -*-
module RS
  def what_is_my_ip
    waybill_client.call(:what_is_my_ip).body.to_hash[:what_is_my_ip_response][:what_is_my_ip_result]
  end

  def update_user(opts)
    validate_presence_of(opts, :username, :password, :ip, :name, :su, :sp)
    response = waybill_client.call :update_service_user, message: {'user_name' => opts[:username], 'user_password' => opts[:password], 'ip' => opts[:ip], 'name' => opts[:name], 'su' => opts[:su], 'sp' => opts[:sp]}
    response.to_hash[:update_service_user_response][:update_service_user_result]
  end

  def check_user(opts)
    validate_presence_of(opts, :su, :sp)
    response = invoice_client.call(:chek, message: { 'su' => opts[:su], 'sp' => opts[:sp] }).to_hash
    { user_id: response[:chek_response][:user_id].to_i, s_user_id: response[:chek_response][:sua].to_i } if response[:chek_response][:chek_result]
  end

  module_function :what_is_my_ip
  module_function :update_user
  module_function :check_user
end
