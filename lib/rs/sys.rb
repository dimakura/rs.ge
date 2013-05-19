# -*- encoding : utf-8 -*-
module RS
  def what_is_my_ip
    waybill_client.call(:what_is_my_ip).body.to_hash[:what_is_my_ip_response][:what_is_my_ip_result]
  end

  def create_user(opts)
    validate_presence_of(opts, :username, :password, :ip, :name, :su, :sp)
    message = {'user_name' => opts[:username], 'user_password' => opts[:password], 'ip' => opts[:ip], 'name' => opts[:name], 'su' => opts[:su], 'sp' => opts[:sp]}
    response = waybill_client.call :create_service_user, message: message
    response.to_hash[:create_service_user_response][:create_service_user_result]
  end

  module_function :what_is_my_ip
  module_function :create_user
end
