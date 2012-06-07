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

describe 'create service user' do
  before(:all) do
    @username = "user_#{Time.now.to_i}_#{rand(100)}"
    @password = '123456'
    @ip = RS.sys.what_is_my_ip
    @resp = RS.sys.create_user(USER01.merge(ip: @ip, name: 'test', su: @username, sp: @password))
  end
  subject { @resp }
  it { should == true }
  describe 'update service user' do
    before(:all) do
      @new_password = 'new_password_123456'
      @resp = RS.sys.update_user(USER01.merge(ip: @ip, name: 'test', su: @username, sp: @new_password))
    end
    subject { @resp }
    it { should == true }
  end
end
