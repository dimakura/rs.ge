# -*- encoding : utf-8 -*-

class RS::Factura
  STATUS_START = 0
  STATUS_SENT  = 1
  STATUS_CONFIRMED = 2

  attr_accessor :id
  attr_accessor :index
  attr_accessor :number
  attr_accessor :operation_date
  attr_accessor :registration_date
  attr_accessor :seller_id
  #attr_accessor :buyer_id
  attr_accessor :status
  attr_accessor :waybill_number
  attr_accessor :waybill_date
  attr_accessor :correction_of
end
