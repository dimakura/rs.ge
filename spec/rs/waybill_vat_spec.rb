# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'კლიენტი დღგ-ს განაკვეთით' do
  before(:all) do
    @waybill = waybill_skeleton
    @waybill.buyer_tin = '204383176'
    @waybill.buyer_name = 'შსს საკადრო და ორგანიზაციული უზრუნველყოფის დეპარტ. საფინანსო-სამეურნეო უზრუნველყოფის მთავარი სამმ-ლო'
    @waybill.items[0].vat_type = RS::Waybill::VAT_COMMON
    RS.save_waybill(@waybill, RS.su_params)
    RS.activate_waybill(RS.su_params.merge('waybill_id' => @waybill.id))
    RS.close_waybill(RS.su_params.merge('waybill_id' => @waybill.id))
    @error = RS.save_waybill_invoice(@waybill, RS.su_params)
    @waybill = RS.get_waybill(RS.su_params.merge('waybill_id' => @waybill.id))
  end
  subject { @error }
  it { should == 1 }
end
