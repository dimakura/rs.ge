# -*- encoding : utf-8 -*-
require 'singleton'

module RS
  # System administration related methods.
  class SysRequest < BaseRequest
    include Singleton

    # Get your outside IP address.
    def what_is_my_ip
      response = waybill_client.request 'what_is_my_ip'
      response.to_hash[:what_is_my_ip_response][:what_is_my_ip_result].strip
    end

    # Create service user.
    #
    # * `username` -- login for the main user
    # * `password` -- password for the main user
    # * `ip` -- your IP address
    # * `name` -- some name for this user/ip configuration
    # * `su` -- new user login
    # * `sp` -- new user password
    def create_user(opts = {})
      validate_presence_of(opts, :username, :password, :ip, :name, :su, :sp)
      response = waybill_client.request 'create_service_user' do
        soap.body = {'user_name' => opts[:username], 'user_password' => opts[:password], 'ip' => opts[:ip], 'name' => opts[:name], 'su' => opts[:su], 'sp' => opts[:sp]}
      end
      response.to_hash[:create_service_user_response][:create_service_user_result]
    end

    # Update service user.
    #
    # * `username` -- login for the main user
    # * `password` -- password for the main user
    # * `ip` -- your IP address
    # * `name` -- some name for this user/ip configuration
    # * `su` -- user login
    # * `sp` -- user's passwrod
    def update_user(opts = {})
      validate_presence_of(opts, :username, :password, :ip, :name, :su, :sp)
      response = waybill_client.request 'update_service_user' do
        soap.body = {'user_name' => opts[:username], 'user_password' => opts[:password], 'ip' => opts[:ip], 'name' => opts[:name], 'su' => opts[:su], 'sp' => opts[:sp]}
      end
      response.to_hash[:update_service_user_response][:update_service_user_result]
    end
  end

  class << self
    def sys
      RS::SysRequest.instance
    end
  end
end
