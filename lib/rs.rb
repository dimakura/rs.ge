require 'savon'
require 'rs/version'
require 'rs/sys'

module RS
  # ელქტრონული ზედნადების ფორმის WSDL მისამართი
  WAYBILL_SERVICE_URL = 'http://services.rs.ge/WayBillService/WayBillService.asmx?WSDL'

  # შეცდომის კლასი
  class Error < RuntimeError
  end

  protected

  # SOAP სერვისის კლიენტი
  def self.service_client
    Savon::Client.new do
      wsdl.document = WAYBILL_SERVICE_URL
    end
  end

  # ამოწმებს პარამეტრის არსებობას
  def self.ensure_params(params, *options)
    options.each do |opt|
      val = params[opt.to_s]
      raise RS::Error.new("#{opt.to_s} required") if val.nil? or val.strip.empty?
    end if options
  end

end
