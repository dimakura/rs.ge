# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec::Matchers.define :have_error_field do |fld|
  match { |obj| !obj.errors[fld].blank? }
end

describe 'WaybillItem validation' do
  before(:all) do
    @item = RS::WaybillItem.new
    @item.validate
  end
  subject { @item }
  it { should have_error_field :bar_code }
  it { should have_error_field :prod_name }
  it { should have_error_field :unit_id }
  it { should_not have_error_field :unit_name }
  it { should have_error_field :quantity }
  it { should have_error_field :price }
  context 'define bar-code' do
    before(:all) do
      @item.bar_code = '001'
      @item.validate
    end
    subject { @item }
    it { should_not have_error_field :bar_code }
  end
  context 'define production-name' do
    before(:all) do
      @item.prod_name = 'tomato'
      @item.validate
    end
    subject { @item }
    it { should_not have_error_field :prod_name }
  end
  context 'define unit = 99' do
    before(:all) do
      @item.unit_id = RS::UNIT_OTHERS
      @item.validate
    end
    subject { @item }
    it { should_not have_error_field :unit_id }
    it { should have_error_field :unit_name }
    context('add unit-name') do
      before(:all) do
        @item.unit_name = 'kg'
        @item.validate
      end
      subject { @item }
      it { should_not have_error_field :unit_id }
      it { should_not have_error_field :unit_name }
    end
  end
  context 'define q < 0' do
    before(:all) do
      @item.quantity = -100
      @item.validate
    end
    subject { @item }
    it { should have_error_field :quantity }
  end
  context 'define q > 0' do
    before(:all) do
      @item.quantity = +100
      @item.validate
    end
    subject { @item }
    it { should_not have_error_field :quantity }
  end
  context 'define p < 0' do
    before(:all) do
      @item.price = -10
      @item.validate
    end
    subject { @item }
    it { should have_error_field :price }
  end
  context 'define p >0' do
    before(:all) do
      @item.price = +10
      @item.validate
    end
    subject { @item }
    it { should_not have_error_field :price }
  end
end
