# -*- encoding : utf-8 -*-
module RS
  WAYBILL_SERVICE_URL = 'http://services.rs.ge/WayBillService/WayBillService.asmx?WSDL'
  INVOICE_SERVICE_URL = 'http://www.revenue.mof.ge/ntosservice/ntosservice.asmx?WSDL'

  def valid_tin?(tin)
    not not (tin =~ /^[0-9]{9}$|^[0-9]{11}$/)
  end
  module_function :valid_tin?

  def waybill_client
    Savon.client(wsdl: WAYBILL_SERVICE_URL)
  end

  def what_is_my_ip
    waybill_client.call(:what_is_my_ip).body.to_hash[:what_is_my_ip_response][:what_is_my_ip_result]
  end
end
