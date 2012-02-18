# -*- encoding : utf-8 -*-
require 'spec_helper'

IP_PATTERN = /^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$/

describe 'what is my IP' do
  before(:all) do
    @ip = RS.what_is_my_ip
  end
  subject { @ip }
  it { should match IP_PATTERN }
end

describe 'get service users' do
  before(:all) do
    @org = RS::TEST_ORG1
    @users = RS.get_service_users(RS.auth_params)
  end
  subject { @users }
  it { should_not be_empty }
  context 'one of the users' do
    subject { @users.first }
    it('should not have empty ID') { subject.id.should_not be_nil }
    it('should not have empty USER_NAME') { subject.user_name.should_not be_nil }
    it('should not have empty PAYER_ID') { subject.payer_id.should_not be_nil }
    it('should have correct IP') { subject.ip.should match IP_PATTERN }
    it('should have some NAME') { subject.name.should_not be_nil }
  end
end

describe 'check service user' do
  before(:all) do
    @user = RS.check_service_user(RS.su_params)
  end
  subject { @user }
  it { should be_instance_of User }
  its(:id)        { should_not be_nil }
  its(:payer_id)  { should_not be_nil }
  its(:user_name) { should_not be_nil }
  its(:user_name) { should == RS::SU_NAME }
  its(:name)      { should be_nil }
  its(:ip)        { should be_nil }
end

describe 'check service user with illegal password' do
  before(:all) do
    @user = RS.check_service_user('su' => RS::SU_NAME, 'sp' => 'someincorrectpassword')
  end
  subject { @user }
  it { should be_nil }
end

describe 'update service user' do
  before(:all) do
    @org  = RS::TEST_ORG1
    @ip   = RS.what_is_my_ip
    @resp = RS.update_service_user( RS.auth_params.merge(RS.su_params).merge({ 'ip' => @ip, 'name' => 'c12' }) )
  end
  subject { @resp }
  it { should be_true }
end
