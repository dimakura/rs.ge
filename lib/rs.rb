# -*- encoding : utf-8 -*-
require 'savon'
require 'rs/version'

# models
require 'rs/models/waybill'

# requests
require 'rs/requests/config'
require 'rs/requests/base'
require 'rs/requests/dict'
require 'rs/requests/sys'
require 'rs/requests/waybill'

module RS
  # This constant indicates 18% vat tariff.
  VAT_COMMON = 0
  # This constant indicates 0% vat tariff.
  VAT_ZERO   = 1
  # This constant indicates that no vat tariff applies.
  VAT_NONE   = 2
end
