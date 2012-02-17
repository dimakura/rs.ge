# -*- encoding : utf-8 -*-

module RS

  # სერვისის მომხმარებლის კლასი.
  class User
    attr_accessor :id, :user_name, :payer_id, :ip, :name
  end

  # აბრუნებს თქვენი კომპიუტერის გარე IP მისამართს.
  def self.what_is_my_ip
    client = RS.service_client
    response = client.request 'what_is_my_ip'
    response.to_hash[:what_is_my_ip_response][:what_is_my_ip_result]
  end

  # გადასაცემია შემდეგი პარამეტრები:
  #
  # user_name -- მომხმარებლის სახელი
  # user_password -- მომხმარებლი პაროლი
  #
  # ბრუნდება #{User}-ების მასივი.
  def self.get_service_users(params)
    RS.ensure_params(params, 'user_name', 'user_password')
    client = RS.service_client
    response = client.request 'get_service_users' do
      soap.body = params
    end
    users_hash_array = response.to_hash[:get_service_users_response][:get_service_users_result][:service_users][:service_user]
    #puts users_hash_array
    users = []
    users_hash_array.each do |user_hash|
      user = User.new
      user.id        = user_hash[:id]
      user.user_name = user_hash[:user_name]
      user.payer_id  = user_hash[:un_id]
      user.ip        = user_hash[:ip]
      user.name      = user_hash[:name]
      users << user
    end
    users
  end

  # გადაეცემა შემდეგი პარამეტრები:
  #
  # su -- სერვისის მომხმარებელი
  # sp -- სერვისის მომხმარებლის პაროლი
  #
  # აბრუნებს #{User} ობიექტს, ცარიელი ip-თი ან <code>nil</code>-ს თუ არასწორი მომხმარებელია.
  def self.check_service_user(params)
    RS.ensure_params(params, 'su', 'sp')
    client = RS.service_client
    response = client.request 'chek_service_user' do
      soap.body = params
    end
    if response[:chek_service_user_response][:chek_service_user_result]
      payer_id = response[:chek_service_user_response][:un_id]
      user_id  = response[:chek_service_user_response][:s_user_id]
      user = User.new
      user.id = user_id
      user.user_name = params['su']
      user.payer_id = payer_id
      user
    end
  end

  

end
