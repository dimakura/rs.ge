# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'getting own IP address' do
  before(:all) do
    @ip = RS.sys.what_is_my_ip
  end
  subject { @ip }
  it { should_not be_nil }
  it { should_not be_empty }
  it { should match /([0-9]{1,3}\.){3}[0-9]{1,3}/ }
end

describe 'working with service user' do
  before(:all) do
    @username = "tbilisi"
    @password = '123456'
    @new_password = 'new_password_123456'
    @ip = RS.sys.what_is_my_ip
  end
  describe 'update service user' do
    before(:all) do
      @resp = RS.sys.update_user(USER01.merge(ip: @ip, name: 'test', su: RS.config.su, sp: RS.config.sp))
    end
    subject { @resp }
    it { should == true }
  end
  describe 'check service user: illegal user/password' do
    before(:all) do
      @resp = RS.sys.check_user(su: RS.config.su, sp: 'illegal password')
    end
    subject { @resp }
    it { should be_nil }
  end
  describe 'check service user: legal user/password' do
    before(:all) do
      @resp = RS.sys.check_user(su: RS.config.su, sp: RS.config.sp)
    end
    subject { @resp }
    it { should_not be_nil }
    specify { subject[:payer].should_not be_nil }
    specify { subject[:user].should_not be_nil }
  end
end

describe 'get error codes' do
  before(:all) do
    @errors = RS.sys.error_codes
  end
  subject { @errors }
  it { should_not be_nil }
  it { should_not be_empty }
  context 'known error codes' do
    subject { @errors[-2001] }
    it { should == 'პროდუქტის დასახელება დიდია' }
  end
end

describe 'get service users list' do
  before(:all) do
    @users = RS.sys.get_users(username: 'tbilisi', password: '123456')
  end
  subject { @users }
  it { should_not be_empty }
  its(:size) { should > 50 }
end
