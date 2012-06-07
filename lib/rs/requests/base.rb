# -*- encoding : utf-8 -*-
require 'savon'

# This class is the base for other request classes.
#
class RS::BaseRequest
  # Waybill service WSDL location.
  WAYBILL_SERVICE_URL = 'http://services.rs.ge/WayBillService/WayBillService.asmx?WSDL'

  # Defaults
  DEFAULTS = {su: 'dimitri1979', sp: '123456'}

  # Getting Savon client.
  def waybill_client
    Savon::Client.new { wsdl.document = WAYBILL_SERVICE_URL }
  end

  # Validates presence of specified keys in the #{params} hash.
  def validate_presence_of(params, *keys)
    # XXX: do we always need this replacement???
    [:su, :sp].each do |sym|
      if keys.include?(sym) and params[sym].blank?
        params[sym] = RS.config.send(sym)
      end
    end
    # <-- XXX
    diff = keys - params.keys
    raise ArgumentError, "The following parameter(s) not specified: #{diff.to_s[1..-2]}" unless diff.empty?
  end
end
