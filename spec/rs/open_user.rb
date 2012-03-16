# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'rs'

describe 'get name from TIN using open user' do
  before(:all) do
    @name = RS.get_name_from_tin('tin' => '02001000490')
  end
  subject { @name }
  it { should == 'დიმიტრი ყურაშვილი' }
end
