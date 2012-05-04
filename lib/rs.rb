# -*- encoding : utf-8 -*-
require 'savon'
require 'rs/version'

# models
require 'rs/models/waybill_unit'

# requests
require 'rs/requests/base_request'
require 'rs/requests/waybill_unit_request'

module RS
  # This constant indicates 18% vat tariff.
  VAT_COMMON = 0
  # This constant indicates 0% vat tariff.
  VAT_ZERO   = 1
  # This constant indicates that no vat tariff applies.
  VAT_NONE   = 2
end
