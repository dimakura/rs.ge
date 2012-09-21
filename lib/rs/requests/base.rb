# -*- encoding : utf-8 -*-
require 'savon'

# This class is the base for other request classes.
#
class RS::BaseRequest
  # Waybill service WSDL location.
  WAYBILL_SERVICE_URL = 'http://services.rs.ge/WayBillService/WayBillService.asmx?WSDL'

  # Invoice service WSDL location.
  INVOICE_SERVICE_URL = 'http://www.revenue.mof.ge/ntosservice/ntosservice.asmx?WSDL'

  # Defaults
  DEFAULTS = {su: 'dimitri1979', sp: '123456', payer_id: 731937, user_id: 783}

  # Last error code.
  attr_accessor :last_error_code

  # Getting waybill SOAP client.
  def waybill_client
    Savon::Client.new { wsdl.document = WAYBILL_SERVICE_URL }
  end

  # Getting waybill SOAP client.
  def invoice_client
    Savon::Client.new { wsdl.document = INVOICE_SERVICE_URL }
  end

  # Validates presence of specified keys in the #{params} hash.
  def validate_presence_of(params, *keys)
    # XXX: do we always need this replacement???
    [:su, :sp, :user_id, :payer_id].each do |sym|
      if keys.include?(sym) and params[sym].blank?
        params[sym] = RS.config.send(sym)
      end
    end
    # <-- XXX
    diff = keys - params.keys
    raise ArgumentError, "The following parameter(s) not specified: #{diff.to_s[1..-2]}" unless diff.empty?
  end

  def format_date(dt)
    dt.strftime('%Y-%m-%dT%H:%M:%S')
  end

end
