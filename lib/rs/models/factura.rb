# -*- encoding : utf-8 -*-

class RS::Factura
  # Source invoice -- პირველადი ა/ფ
  STATUS_START = 0
  STATUS_SENT  = 1
  STATUS_CONFIRMED = 2
  STATUS_CORRECTED = 3
  # Correction invoice -- კორექტირებული ა/ფ
  STATUS_CORR_START = 4
  STATUS_CORR_SENT = 5
  STATUS_CORR_CONFIRMED = 8
  # Canceled -- გაუქმებულია
  STATUS_CANCELED = 6
  STATUS_CONFIRMED_CANCELED = 7

  attr_accessor :id
  attr_accessor :index, :number
  attr_accessor :operation_date, :registration_date
  attr_accessor :seller_id, :buyer_id
  attr_accessor :status
  attr_accessor :waybill_number, :waybill_date
  attr_accessor :correction_of
end