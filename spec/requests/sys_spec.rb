# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'check IP response' do
  before(:all) do
    @ip = RS.sys.what_is_my_ip
  end
  subject { @ip }
  it { should_not be_nil }
  it { should_not be_empty }
end