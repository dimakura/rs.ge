# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'rs'

describe 'save invoice (only for closed waybill)' do
  before(:all) do
    @waybill = waybill_skeleton
    RS.save_waybill(@waybill, RS.su_params)
    RS.activate_waybill(RS.su_params.merge('waybill_id' => @waybill.id))
    RS.close_waybill(RS.su_params.merge('waybill_id' => @waybill.id))
    RS.save_waybill_invoice(@waybill, RS.su_params)
  end
  subject { @waybill }
  its(:invoice_id) { should_not be_nil }
  its(:invoice_id) { should > 0 }
end

# TODO: როდესაც არაა დღგ-ს გადამხდელი ვერ აგზავნი?!