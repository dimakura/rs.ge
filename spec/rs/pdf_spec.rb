# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'rs'

describe 'printing waybill PDF' do
  before(:all) do
    @waybill = waybill_skeleton
    #@file = File.new File.expand_path('tmp/waybill.pdf')
    RS.print_waybill(@waybill, file)

  end
  subject { file }
  it { should == 'file' }
end
