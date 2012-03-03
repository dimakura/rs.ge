# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'rs'

describe 'printing waybill PDF' do
  before(:all) do
    @waybill = waybill_skeleton
    @waybill.number = '000003123'
    @waybill.activate_date = Time.now
    @waybill.seller_tin = '12345678901'
    @waybill.seller_name = 'შპს ც12'
    @path = File.expand_path('tmp/waybill.pdf')
    RS.print_waybill(@waybill, @path)
  end
  subject { @waybill }
  it { should_not be_nil }
end
