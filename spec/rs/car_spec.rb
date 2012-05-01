# -*- encoding : utf-8 -*-

require 'spec_helper'

def valid_vehicle_number(number)
  describe "#{number} სწორი სახელმწიფო ნომერია" do
    it { RS.valid_vehicle_number?(number).should == true }
  end
end

def invalid_vehicle_number(number)
  describe "#{number} არასწორი სახელმწიფო ნომერია" do
    it { RS.valid_vehicle_number?(number).should == false }
  end
end

describe 'მანქანის ნომრების შემოწმება' do
  valid_vehicle_number 'WDW842'
  valid_vehicle_number 'KFK061'
  valid_vehicle_number 'wdw467'
  valid_vehicle_number 'kfk061'
  invalid_vehicle_number 'WDW-842'
  invalid_vehicle_number 'Subaru WDW842'
  invalid_vehicle_number 'Mercedes KFK061'
end
