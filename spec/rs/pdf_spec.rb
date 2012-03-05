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
    @waybill.delivery_date = Time.now
    @waybill.comment = 'ეს არის სატესტო ზედნადები'
    @waybill.items = @waybill.items * 100
    @path = File.expand_path('tmp/waybill.pdf')
    RS.print_waybill(@waybill, @path, :bottom_text => 'მომზადებულია <u><color rgb="0000FF"><link href="http://invoice.ge">http://invoice.ge</link></color></u>-ზე')
  end
  subject { @waybill }
  it { should_not be_nil }
end
