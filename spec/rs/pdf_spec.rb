# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'rs'

describe 'printing waybill PDF' do
  before(:all) do
    @waybill = waybill_skeleton
    @path = File.expand_path('tmp/waybill.pdf')
    RS.print_waybill(@waybill, @path)
  end
  subject { @waybill }
  it { should_not be_nil }
end
