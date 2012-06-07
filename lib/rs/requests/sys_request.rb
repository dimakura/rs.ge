# -*- encoding : utf-8 -*-
require 'singleton'

module RS
  # System administration related methods.
  class SysRequest < BaseRequest
    include Singleton

    def what_is_my_ip
      response = waybill_client.request 'what_is_my_ip'
      response.to_hash[:what_is_my_ip_response][:what_is_my_ip_result].strip
    end
  end
  
  class << self
    def sys
      RS::SysRequest.instance
    end
  end
end
