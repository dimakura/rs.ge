# -*- encoding : utf-8 -*-
module RS
  class Waybill
    attr_accessor :id, :parent_id, :number, :type, :status, :seller_id
    attr_accessor :buyer_tin, :check_buyer_tin, :buyer_name
    attr_accessor :driver_tin, :check_driver_tin, :driver_name
    attr_accessor :start_address, :end_address
    attr_accessor :create_date, :begin_date, :delivery_date
    attr_accessor :transport_cost, :transport_cost_payer, :vehicle
    attr_accessor :transport_type, :transport_name
    attr_accessor :comment, :seller_info, :buyer_info
    attr_accessor :amount, :su_id
    attr_accessor :items
  end

  class WaybillItem
    attr_accessor :id, :code, :name, :status
    attr_accessor :unit_id, :unit_name
    attr_accessor :quantity, :quantity_ext, :price, :amount
    attr_accessor :excise_id, :vat_type
  end
end
