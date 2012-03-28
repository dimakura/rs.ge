# -*- encoding : utf-8 -*-

require 'spec_helper'
require 'rs'

describe 'save waybill' do
  before(:all) do
    @waybill = waybill_skeleton(:transport_type => nil, :items => [
        { :name => 'კონდოლი საფერავი 0.75 ლ.', :unit_id  => 99, :unit_name => 'ცალი', :quantity => 6, :price => 30.40,  :code => '4867616100014' },
        { :name => 'კონდოლი მწვანე ქისი 0.75 ლ.', :unit_id  => 99, :unit_name => 'ცალი', :quantity => 6, :price => 15.70,  :code => '4867616100045' },
        { :name => 'ყუთი 2ბოთლიანი', :unit_id  => 99, :unit_name => 'ცალი', :quantity => 8, :price => 25.60,  :code => 'TMYUTI2B' },
        { :name => 'მუკუზანი 0.75ლ.', :unit_id  => 99, :unit_name => 'ცალი', :quantity => 8, :price => 19.80,  :code => '4860065010026' },
        { :name => 'ქინძმარაული 0.75ლ.', :unit_id  => 99, :unit_name => 'ცალი', :quantity => 4, :price => 19.40,  :code => '4860065010071' },
        { :name => 'ხვანჭკარა 0.75ლ.', :unit_id  => 99, :unit_name => 'ცალი', :quantity => 1, :price => 29.70,  :code => '4860065010057' },
        { :name => 'წინანდალი დაძველე ბული 0.75ლ.', :unit_id  => 99, :unit_name => 'ცალი', :quantity => 1, :price => 11.50,  :code => '4860065010170' },
        { :name => 'ტვიში 0.75ლ.', :unit_id  => 99, :unit_name => 'ცალი', :quantity => 1, :price => 15.90,  :code => '4860065010293' },
        { :name => 'ჭაჭა დავარგებული 0.5ლ.', :unit_id  => 99, :unit_name => 'ცალი', :quantity => 6, :price => 24.80,  :code => '4860065013775' },
        { :name => '"საფერავი" 0.75ლ.', :unit_id  => 99, :unit_name => 'ცალი', :quantity => 4, :price => 15.50,  :code => 'MUKUZ1' },
      ]
    )
    @waybill.buyer_tin = '204383176'
    @waybill.buyer_name = 'შსს საკადრო და ორგანიზაციული უზრუნველყოფის დეპარტ. საფინანსო-სამეურნეო უზრუნველყოფის მთავარი სამმ-ლო'
    @resp = RS.save_waybill(@waybill, RS.su_params)
  end
  subject { @resp }
  it { should == 0 }
end
