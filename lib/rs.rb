# -*- encoding : utf-8 -*-
require 'savon'
require 'rs/version'

# models

# requests
require 'rs/requests/base_request'
require 'rs/requests/dict_request'
require 'rs/requests/sys_request'

module RS
  # This constant indicates 18% vat tariff.
  VAT_COMMON = 0
  # This constant indicates 0% vat tariff.
  VAT_ZERO   = 1
  # This constant indicates that no vat tariff applies.
  VAT_NONE   = 2
end
