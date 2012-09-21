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
  include RS::Initializable

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
  # Mark this item for deletion.
  attr_accessor :delete

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
      b.STATUS self.delete ? -1 : +1
      b.AMOUNT self.quantity * self.price
      b.BAR_CODE self.bar_code
      b.A_ID (self.excise_id ? self.excise_id : 0)
      b.VAT_TYPE (self.vat_type || RS::VAT_COMMON)
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
  include RS::Initializable

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
  # Waybill creation date.
  attr_accessor :create_date
  # Waybill activation date.
  attr_accessor :activate_date
  # Waybill delivery date.
  attr_accessor :delivery_date
  # Waybill close date.
  attr_accessor :close_date
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
  # Comment on this waybill.
  attr_accessor :comment
  # Waybill items.
  attr_accessor :items
  # Waybill error code.
  attr_accessor :error_code
  # Invoice ID, related to this waybill.
  attr_accessor :invoice_id
  # Full amount of this waybill.
  attr_accessor :total
  # Service user ID, who created this waybill.
  attr_accessor :user_id

  # Convert this waybill to XML.
  def to_xml(xml)
    xml.WAYBILL do |b|
      b.GOODS_LIST do |g|
        (self.items || []).each do |item|
          item.to_xml g
        end
      end
      b.ID (self.id ? self.id : 0)
      b.TYPE self.type
      b.BUYER_TIN self.buyer_tin
      b.CHEK_BUYER_TIN (self.check_buyer_tin ? 1 : 0)
      b.BUYER_NAME self.buyer_name
      b.START_ADDRESS self.start_address
      b.END_ADDRESS self.end_address
      b.DRIVER_TIN self.driver_tin
      b.CHEK_DRIVER_TIN (self.check_driver_tin ? 1 : 0)
      b.DRIVER_NAME self.driver_name
      b.TRANSPORT_COAST (self.transportation_cost ? self.transportation_cost : 0)
      b.RECEPTION_INFO self.seller_info
      b.RECEIVER_INFO self.buyer_info
      b.DELIVERY_DATE (self.delivery_date ? self.delivery_date.strftime('%Y-%m-%dT%H:%M:%S') : '')
      b.STATUS self.status
      b.SELER_UN_ID self.seller_id
      b.PAR_ID (self.parent_id ? self.parent_id : '')
      b.CAR_NUMBER self.car_number
      b.WAYBILL_NUMBER (self.number ? self.number : '')
      ## XXX: b.S_USER_ID
      b.BEGIN_DATE (self.activate_date ? self.activate_date.strftime('%Y-%m-%dT%H:%M:%S') : '')
      b.TRAN_COST_PAYER (self.transportation_cost_payer ? self.transportation_cost_payer : RS::Waybill::TRANSPORTATION_PAID_BY_BUYER)
      b.TRANS_ID self.transport_type_id
      b.TRANS_TXT self.transport_type_name
      b.COMMENT self.comment
    end
  end

  # Initialize this waybill from given hash.
  def init_from_hash(hash)
    items_hash = hash[:goods_list][:goods]
    items_hash = [items_hash] if items_hash.instance_of? Hash
    self.items = []
    items_hash.each do |item_hash|
      item = RS::WaybillItem.new
      item.init_from_hash(item_hash)
      self.items << item
    end
    self.id = hash[:id].to_i
    self.type = hash[:type].to_i
    self.create_date = hash[:create_date]
    self.buyer_tin = hash[:buyer_tin]
    self.check_buyer_tin = hash[:chek_buyer_tin].to_i == 1
    self.buyer_name = hash[:buyer_name]
    self.start_address = hash[:start_address]
    self.end_address = hash[:end_address]
    self.driver_tin = hash[:driver_tin]
    self.check_driver_tin = hash[:chek_driver_tin].to_i == 1
    self.driver_name = hash[:driver_name]
    self.transportation_cost = hash[:transport_coast].to_f
    self.seller_info = hash[:reception_info]
    self.buyer_info = hash[:receiver_info]
    self.delivery_date = hash[:delivery_date] # delivery date
    self.status = hash[:status].to_i
    self.seller_id = hash[:seler_un_id].to_i
    self.activate_date = hash[:activate_date]
    self.parent_id = hash[:par_id]
    self.total = hash[:full_amount].to_f
    self.car_number = hash[:car_number]
    self.number = hash[:waybill_number]
    self.close_date = hash[:close_date]
    self.user_id = hash[:s_user_id].to_i
    self.activate_date = hash[:begin_date]
    self.transportation_cost_payer = hash[:tran_cost_payer] ? hash[:tran_cost_payer].to_i : nil
    self.transport_type_id = hash[:trans_id].to_i
    self.transport_type_name = hash[:trans_txt]
    self.comment = hash[:comment]
    self
  end

  def validate
    self.errors = {}
    self.items.each { |it| it.validate } if self.items
    validate_buyer
    validate_transport
    validate_addresses
    validate_remote if RS.config.validate_remote
  end

  def valid?
    self.items.each { |it| return false unless it.valid? }
    super.valid?
  end

  private

  def validate_buyer
    if self.buyer_tin.blank?
      add_error(:buyer_tin, 'მყიდველის საიდენტიფიკაციო ნომერი განუსაზღვრელია')
    else
      if self.check_buyer_tin
        add_error(:buyer_tin, 'საიდენტიფიკაციო ნომერი უნდა შედგებოდეს 9 ან 11 ციფრისაგან') if !RS.dict.personal_tin?(self.buyer_tin) and !RS.corporate_tin?(self.buyer_tin)
      else
        add_error(:buyer_name, 'განსაზღვრეთ მყიდველის სახელი') if self.buyer_name.blank?
      end
    end
  end

  def validate_transport
    if self.transport_type_id == RS::TRANS_VEHICLE
      add_error(:car_number, 'მიუთითეთ სატრანსპორტო საშუალების სახელმწიფო ნომერი') if self.car_number.blank?
      add_error(:driver_tin, 'მძღოლის პირადი ნომერი უნდა იყოს მითითებული') if self.driver_tin.blank?
      if self.check_driver_tin
        add_error(:driver_tin, 'მძღოლის პირადი ნომერი არასწორია') unless RS.dict.personal_tin?(self.driver_tin)
        # unless RS.valid_vehicle_number?(self.car_number)
        #   RS.append_validation_error(@validation_errors, :car_number, 'არასწორი მანქანის ნომერი: ჩაწერეთ ABC123 ფორმატში!')
        # end
      else
        add_error(:driver_name, 'ჩაწერეთ მძღოლის სახელი') if self.driver_name.blank?
      end
    elsif self.transport_type_id == RS::TRANS_OTHER
      add_error(:transport_type_name, 'მიუთითეთ სატრანსპორტო საშუალების დასახელება') if self.transport_type_name.blank?
    end
  end

  def validate_addresses
    add_error(:start_address, 'საწყისი მისამართი განუსაზღვრელია') if self.start_address.blank?
    add_error(:end_address,   'საბოლოო მისამართი განუსაზღვრელია') if self.end_address.blank?
    if not self.start_address.blank? and not self.end_address.blank? and
      self.start_address.strip != self.end_address.strip and
      self.type == RS::WAYBILL_TYPE_WITHOUT_TRANS
      add_error(:type, '"ტრანსპორტირების გარეშე" დაუშვებელია, როდესაც საწყისი მისამართი არ ემთხვევა საბოლოოს.')
    end
  end

  def validate_remote
    # driver
    if self.transport_type_id == RS::WAYBILL_TYPE_TRANS and self.check_driver_tin
      unless self.driver_tin.blank?
        driver_name = RS.dict.get_name_from_tin(tin: self.driver_tin)
        add_error(:driver_tin, "საიდ. ნომერი ვერ მოიძებნა: #{self.driver_tin}") if driver_name.nil?
        add_error(:driver_name, "მძღოლის სახელია: #{driver_name}") if driver_name and driver_name.split.join(' ') != self.driver_name.split.join(' ')
      else
        # IMPORTANT! this validation is not "remote", so it's moved into non-remote part
        # add_error(:driver_tin, "მძღოლის პირადი ნომერი არაა მითითებული.")
      end
    end
    # buyer
    if self.check_buyer_tin
      unless self.buyer_tin.blank?
        buyer_name = RS.dict.get_name_from_tin(tin: self.buyer_tin)
        add_error(:buyer_tin, "საიდ. ნომერი ვერ მოიძებნა: #{self.buyer_tin}") if buyer_name.nil?
        add_error(:buyer_name, "მყიდველის სახელია: #{buyer_name}") if buyer_name and buyer_name.split.join(' ') != self.buyer_name.split.join(' ')
      else
        # IMPORTANT! this validation is not "remote", so it's moved into non-remote part
        # add_error(:buyer_tin, "მყიდველის პირადი ნომერი არაა მითითებული.")
      end
    end
  end

end
