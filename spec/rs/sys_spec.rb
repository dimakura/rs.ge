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
    @users = RS.get_service_users({'user_name' => @org[:user], 'user_password' => @org[:password]})
  end
  subject { @users }
  it { should_not be_empty }
  context 'one of the users' do
    subject { @users.first }
    it('should not have empty ID') { subject.id.should_not be_nil }
    it('should not have empty USER_NAME') { subject.user_name.should_not be_nil }
    it('should not have empty UN_ID') { subject.taxid.should_not be_nil }
    it('should have correct IP') { subject.ip.should match IP_PATTERN }
    it('should have some NAME') { subject.name.should_not be_nil }
  end
end
