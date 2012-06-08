# -*- encoding : utf-8 -*-
require 'active_support/all'

# Class with errors and warnings.
class RS::Validable
  attr_accessor :errors, :warnings

  # Add error to the specified field.
  def add_error(fld, msg)
    self.errors = {} unless self.errors
    self.errors[fld.to_sym] = msg
  end

  # Add warning to the specified field.
  def add_warning(fld, msg)
    self.warnings = {} unless self.warnings
    self.warnings[fld.to_sym] = msg
  end

  # Valid?
  def valid?
    self.errors.nil? or self.errors.empty?
  end
end

# Waybill item class.
class RS::WaybillItem < RS::Validable
  # Item ID.
  attr_accessor :id
  # Barcode for the production in this item,
  attr_accessor :bar_code
  # Name of the production in this item.
  attr_accessor :prod_name
  # Unit ID.
  attr_accessor :unit_id
  # Unit name.
  attr_accessor :unit_name
  # Quantity.
  attr_accessor :quantity
  # Price.
  attr_accessor :price
  # Excise ID.
  attr_accessor :excise_id
  # VAT type.
  attr_accessor :vat_type

  # Initialize WaybillItem from hash.
  def init_from_hash(hash)
    self.id = hash[:id]
    self.bar_code = hash[:bar_code]
    self.prod_name = hash[:w_name]
    self.unit_id = hash[:unit_id].to_i
    self.unit_name = hash[:unit_txt]
    self.quantity = hash[:quantity].to_f
    self.price = hash[:price].to_f
    self.excise_id = hash[:a_id] == '0' ? nil : hash[:a_id].to_i
  end

  # Convert item to XML.
  def to_xml(xml)
    xml.GOODS do |b|
      b.ID (self.id ? self.id : 0)
      b.W_NAME self.prod_name
      b.UNIT_ID self.unit_id
      b.UNIT_TXT self.unit_name
      b.QUANTITY self.quantity
      b.PRICE self.price
      b.AMOUNT self.quantity * self.price
      b.BAR_CODE self.bar_code
      b.A_ID (self.excise_id ? self.excise_id : 0)
      b.VAT_TYPE (self.vat_type || Waybill::VAT_COMMON)
    end
  end

  # Validate this item.
  def validate
    self.errors = {}
    add_error(:bar_code, 'საქონლის შტრიხ-კოდი უნდა იყოს განსაზღვრული') if self.bar_code.blank?
    add_error(:prod_name, 'საქონლის სახელი არაა განსაზღვრული') if self.prod_name.blank?
    add_error(:unit_id, 'ზომის ერთეული არაა განსაზღვრული') if self.unit_id.blank?
    add_error(:unit_name, 'ზომის ერთეულის სახელი არაა განსაზღვრული') if self.unit_id == RS::UNIT_OTHERS and (self.unit_name.blank?)
    add_error(:quantity, 'რაოდენობა უნდა იყოს მეტი 0-ზე') if self.quantity.blank? or self.quantity <= 0
    add_error(:price, 'ფასი არ უნდა იყოს უარყოფითი') if self.price.blank? or self.price < 0
  end

end

# Waybill class.
class RS::Waybill < RS::Validable
  # Constant, which indicates, that transportation cost is paid by buyer.
  TRANSPORTATION_PAID_BY_BUYER  = 1
  # Constant, which indicates, that transportation cost is paid by seller.
  TRANSPORTATION_PAID_BY_SELLER = 2

  # Deleted waybill status.
  STATUS_DELETED  = -1
  # Deactivated waybill status.
  STATUS_DEACTIVATED = -2
  # Saved waybill status.
  STATUS_SAVED   =  0
  # Active waybill status.
  STATUS_ACTIVE  =  1
  # Closed (complete) waybill status.
  STATUS_CLOSED  =  2

  # ID of the waybill
  attr_accessor :id
  # Waybill type (see RS::WAYBILL_TYPES).
  attr_accessor :type
  # Waybill status.
  attr_accessor :status
  # Parent waybill (for subwaybills).
  attr_accessor :parent_id
  # Waybill number.
  attr_accessor :number
  # Waybill activation date.
  attr_accessor :activate_date
  # Waybill delivery date.
  attr_accessor :delivery_date
  # Unique ID of the seller
  attr_accessor :seller_id
  # Seller TIN.
  attr_accessor :seller_tin
  # Seller name.
  attr_accessor :seller_name
  # Buyer TIN.
  attr_accessor :buyer_tin
  # Whether buyer TIN should be validated.
  # Use `false` for foreigner.
  attr_accessor :check_buyer_tin
  # Buyer name.
  attr_accessor :buyer_name
  # Information about a person, who sends this waybill.
  attr_accessor :seller_info
  # Information about a person, who receives this waybill.
  attr_accessor :buyer_info
  # Driver TIN.
  attr_accessor :driver_tin
  # Whether driver TIN should be validated.
  # Use `false` for foreigner.
  attr_accessor :check_driver_tin
  # Driver name.
  attr_accessor :driver_name
  # Waybill start address.
  attr_accessor :start_address
  # Waybill end address.
  attr_accessor :end_address
  # Transportation cost.
  attr_accessor :transportation_cost
  # Who pays for transportation?
  attr_accessor :transportation_cost_payer
  # Transportation type (see RS::TRANSPORT_TYPES).
  attr_accessor :transport_type_id
  # Transportation name.
  attr_accessor :transport_type_name
  # Vehicle number.
  attr_accessor :car_number
  # ==> XXX: there should be some flag which indicates whether vehicle number should be checked
  # Comment on this waybill.
  attr_accessor :comment
  # Waybill items.
  attr_accessor :items
  # Waybill error code.
  attr_accessor :error_code
  # Invoice ID, related to this waybill.
  attr_accessor :invoice_id

end
