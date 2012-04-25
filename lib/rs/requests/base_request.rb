# -*- encoding : utf-8 -*-
require 'savon'

# This class is the base for other request classes.
#
class RS::BaseRequest
  # Waybill service WSDL location.
  WAYBILL_SERVICE_URL = 'http://services.rs.ge/WayBillService/WayBillService.asmx?WSDL'

  # Getting Savon client.
  def waybill_client
    Savon::Client.new { wsdl.document = WAYBILL_SERVICE_URL }
  end

  # Validates presence of specified keys in the #{params} hash.
  def validate_presence_of(params, *keys)
    diff = keys - params.keys
    raise ArgumentError, "The following parameter(s) not specified: #{diff.to_s[1..-2]}" unless diff.empty?
  end
end
