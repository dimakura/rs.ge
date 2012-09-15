require 'singleton'

module RS

  # Invoice requests.
  class InvoiceRequest < BaseRequest
    include Singleton


  end

  class << self
    def inv
      RS::InvoiceRequest.instance
    end

    def invoice
      RS::InvoiceRequest.instance
    end
  end

end