# encoding: utf-8

module RS

  class User
    attr_accessor :id, :user_name, :taxid, :ip, :name
  end

  def self.what_is_my_ip
    client = RS.service_client
    response = client.request 'what_is_my_ip'
    response.to_hash[:what_is_my_ip_response][:what_is_my_ip_result]
  end

  def self.get_service_users(params)
    RS.ensure_params(params, 'user_name', 'user_password')
    client = RS.service_client
    response = client.request 'get_service_users' do
      soap.body = params
    end
    users_hash_array = response.to_hash[:get_service_users_response][:get_service_users_result][:service_users][:service_user]
    users = []
    users_hash_array.each do |user_hash|
      user = User.new
      user.id = user_hash[:id]
      user.user_name = user_hash[:user_name]
      user.taxid = user_hash[:un_id]
      user.ip = user_hash[:ip]
      user.name = user_hash[:name]
      users.push(user)
    end
    users
  end

end
