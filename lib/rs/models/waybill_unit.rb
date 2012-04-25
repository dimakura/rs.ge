# -*- encoding : utf-8 -*-

# WaybillUnit is a unit which is used to describe production quantities in waybill.
#
# The Revenue Service of Georgia provides us with standard set of units,
# which can be obtained using RS.waybill_units method call.
#
# One special unit, is the unit which describes all units which were not included
# in the Revenue Service list. Identification number for this special unit is
# stored in contant RS::WaybillUnit::OTHERS.
class RS::WaybillUnit
  # Unit ID.
  attr_accessor :id

  # Unit name,
  attr_accessor :name

  # Identification number for the unit, which were not included in
  # the Revenue Service list of units.
  OTHERS = 99
end
