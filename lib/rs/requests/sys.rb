# -*- encoding : utf-8 -*-
require 'singleton'

module RS
  class User
    include RS::Initializable
    attr_accessor :id, :username, :ip, :name, :payer_id
    def self.extract(data); RS::User.new(id: data[:id].to_i, username: data[:user_name], ip: data[:ip], name: data[:name], payer_id: data[:un_id].to_i) end
  end

  # System administration related methods.
  class SysRequest < BaseRequest
    include Singleton

    # Get your outside IP address.
    def what_is_my_ip
      response = waybill_client.request 'what_is_my_ip'
      response.to_hash[:what_is_my_ip_response][:what_is_my_ip_result].strip
    end

    # # Create service user.
    # #
    # # * `username` -- login for the main user
    # # * `password` -- password for the main user
    # # * `ip` -- your IP address
    # # * `name` -- some name for this user/ip configuration
    # # * `su` -- new user login
    # # * `sp` -- new user password
    # def create_user(opts)
    #   validate_presence_of(opts, :username, :password, :ip, :name, :su, :sp)
    #   response = waybill_client.request 'create_service_user' do
    #     soap.body = {'user_name' => opts[:username], 'user_password' => opts[:password], 'ip' => opts[:ip], 'name' => opts[:name], 'su' => opts[:su], 'sp' => opts[:sp]}
    #   end
    #   response.to_hash[:create_service_user_response][:create_service_user_result]
    # end

    def get_users(opts)
      validate_presence_of(opts, :username, :password)
      response = (waybill_client.request 'get_service_users' do
              soap.body = { 'user_name' => opts[:username], 'user_password' => opts[:password] }
            end).to_hash
      if response[:get_service_users_response][:get_service_users_result][:service_users].blank?
        raise 'illegal username/password'
      else
        users = []
        users_data = response[:get_service_users_response][:get_service_users_result][:service_users][:service_user]
        if users_data.is_a?(Array)
          users_data.each { |data| users << RS::User.extract(data) }
        else
          users << RS::User.extract(users_data)
        end
        users
      end
    end

    # Update service user.
    #
    # * `username` -- login for the main user
    # * `password` -- password for the main user
    # * `ip` -- your IP address
    # * `name` -- some name for this user/ip configuration
    # * `su` -- user login
    # * `sp` -- user's passwrod
    def update_user(opts)
      validate_presence_of(opts, :username, :password, :ip, :name, :su, :sp)
      response = waybill_client.request 'update_service_user' do
        soap.body = {'user_name' => opts[:username], 'user_password' => opts[:password], 'ip' => opts[:ip], 'name' => opts[:name], 'su' => opts[:su], 'sp' => opts[:sp]}
      end
      response.to_hash[:update_service_user_response][:update_service_user_result]
    end

    # Check service user. Also used for getting user's ID and payer's ID.
    #
    # possible parameters:
    #
    # `su` -- service username
    # `sp` -- service password
    # 
    # Returns hash with the following structure:
    #
    # ```
    # {payer: 'payer unique ID', user: 'user unique ID'}
    # ```
    def check_user(opts)
      validate_presence_of(opts, :su, :sp)
      response = waybill_client.request 'chek_service_user' do
        soap.body = {'su' => opts[:su], 'sp' => opts[:sp] }
      end
      if response[:chek_service_user_response][:chek_service_user_result]
        payer_id = response[:chek_service_user_response][:un_id]
        user_id  = response[:chek_service_user_response][:s_user_id]
        {payer: payer_id, user: user_id}
      end
    end

    # Returns error codes.
    def error_codes(opts = {})
      validate_presence_of(opts, :su, :sp)
      response = waybill_client.request 'get_error_codes' do
        soap.body = {'su' => opts[:su], 'sp' => opts[:sp] }
      end
      errors = {}
      response[:get_error_codes_response][:get_error_codes_result][:error_codes][:error_code].each do |el|
        errors[el[:id].to_i] = el[:text]
      end
      errors
    end

  end

  class << self
    def sys
      RS::SysRequest.instance
    end

    def system
      RS::SysRequest.instance
    end
  end

end
