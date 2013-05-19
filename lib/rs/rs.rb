# -*- encoding : utf-8 -*-
require 'rs/sys'

module RS
  WAYBILL_SERVICE_URL = 'http://services.rs.ge/WayBillService/WayBillService.asmx?WSDL'
  INVOICE_SERVICE_URL = 'http://www.revenue.mof.ge/ntosservice/ntosservice.asmx?WSDL'

  def valid_tin?(tin)
    not not (tin =~ /^[0-9]{9}$|^[0-9]{11}$/)
  end

  def waybill_client
    Savon.client(wsdl: WAYBILL_SERVICE_URL)
  end

  module_function :valid_tin?
  module_function :waybill_client
end
