# -*- encoding : utf-8 -*-
require 'savon'
require 'rs/version'
require 'rs/sys'
require 'rs/dict'

module RS
  # ელქტრონული ზედნადების ფორმის WSDL მისამართი
  WAYBILL_SERVICE_URL = 'http://services.rs.ge/WayBillService/WayBillService.asmx?WSDL'

  # ელექტრონული ა/ფ WSDL მისამართი
  INVOICE_SERVICE_URL = 'https://www.revenue.mof.ge/ntosservice/ntosservice.asmx?WSDL'

  # შეცდომის კლასი
  class Error < RuntimeError
  end

  protected

  # ელექტრონული ზედნადების SOAP კლიენტის მიღება
  def self.waybill_service
    Savon::Client.new do
      wsdl.document = WAYBILL_SERVICE_URL
    end
  end

  # ანგარიშ-ფაქტურის SOAP კლიენტის მიღება
  def self.invoice_service
    Savon::Client.new do
      wsdl.document = INVOICE_SERVICE_URL
    end
  end

  # ამოწმებს, რომ მოცემულ პარამეტრებში ყველას მნიშვნელობა განსხვავდებოდეს <code>nil</code>-სგან.
  def self.validate_presence_of(params, *options)
    options.each do |opt|
      val = params[opt.to_s]
      raise RS::Error.new("#{opt.to_s} required") if val.nil? or (val.instance_of? String and val.strip.empty?)
    end if options
  end

  # უზრუნველყოფს <code>nil</code> მნიშვნელობების სწორად ჩაწერას.
  def self.prepare_params(params)
    attributes = {}
    params.each do |k, v|
      if v.nil?
        params.delete k
        attributes[k] = {'xsi:nil' => true}
      end
    end
    params['attributes!'] = attributes unless attributes.empty?
  end

end
