# -*- encoding : utf-8 -*-
module RS
  WAYBILL_SERVICE_URL = 'http://services.rs.ge/WayBillService/WayBillService.asmx?WSDL'
  INVOICE_SERVICE_URL = 'http://www.revenue.mof.ge/ntosservice/ntosservice.asmx?WSDL'

  def valid_tin?(tin)
    not not (tin =~ /^[0-9]{9}$|^[0-9]{11}$/)
  end

  def waybill_client
    Savon.client(wsdl: WAYBILL_SERVICE_URL, log: false)
  end

  def invoice_client
    Savon.client(wsdl: INVOICE_SERVICE_URL, log: false)
  end

  module_function :valid_tin?
  module_function :waybill_client
  module_function :invoice_client

  protected

  # Validates presence of specified keys in the `params` hash.
  def validate_presence_of(params, *keys)
    [:su, :sp, :user_id, :payer_id].each do |sym|
      if keys.include?(sym) and params[sym].blank?
        # params[sym] = RS.config.send(sym)
      end
    end
    diff = keys - params.keys
    raise ArgumentError, "The following parameter(s) not specified: #{diff.to_s}" unless diff.empty?
  end

  module_function :validate_presence_of
end
