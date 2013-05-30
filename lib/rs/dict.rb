# -*- encoding : utf-8 -*-
module RS
  UNITS_OTHER = 99

  # Excise code.
  class ExciseCode
    attr_reader :id
    attr_reader :name
    attr_reader :code
    attr_reader :unit
    attr_reader :price

    def initialize(h)
      @id = h[:id].to_i
      @name = h[:title][0..(h[:title].index('(') - 1)].strip
      @code = h[:sakon_kodi]
      @unit = h[:measurement]
      @price = h[:akcis_ganakv].to_f
    end
  end

  def get_oranizaton_info_from_tin(opts)
    validate_presence_of(opts, :su, :sp, :tin, :user_id)
    message = { 'user_id' => opts[:user_id], 'tin' => opts[:tin], 'su' => opts[:su], 'sp' => opts[:sp] }
    response = invoice_client.call(:get_un_id_from_tin, message: message).to_hash
    id = response[:get_un_id_from_tin_response][:get_un_id_from_tin_result]
    name = response[:get_un_id_from_tin_response][:name]
    { id: id.to_i, name: name }
  end

  def is_vat_payer(opts)
    validate_presence_of(opts, :su, :sp, :payer_id)
    message = { 'su' => opts[:su], 'sp' => opts[:sp], 'un_id' => opts[:payer_id] }
    response = waybill_client.call(:is_vat_payer, message: message).to_hash
    response[:is_vat_payer_response][:is_vat_payer_result]
  end

  def get_name_from_tin(opts)
    validate_presence_of(opts, :su, :sp, :tin)
    response = waybill_client.call :get_name_from_tin, message: { su: opts[:su], sp: opts[:sp], tin: opts[:tin] }
    response.to_hash[:get_name_from_tin_response][:get_name_from_tin_result]
  end

  def get_units(opts)
    validate_presence_of(opts, :su, :sp)
    response = waybill_client.call(:get_waybill_units, message: { 'su' => opts[:su], 'sp' => opts[:sp] })
    resp = response.to_hash[:get_waybill_units_response][:get_waybill_units_result][:waybill_units][:waybill_unit]
    Hash[resp.map { |x| [ x[:id].to_i, x[:name] ] }]
  end

  def get_excise_codes(opts)
    validate_presence_of(opts, :su, :sp)
    response = waybill_client.call(:get_akciz_codes, message: { 'su' => opts[:su], 'sp' => opts[:sp], 's_text' => '' }).to_hash
    data = response[:get_akciz_codes_response][:get_akciz_codes_result][:akciz_codes][:akciz_code]
    data.map { |code| ExciseCode.new(code) }
  end

  module_function :get_oranizaton_info_from_tin
  module_function :is_vat_payer
  module_function :get_name_from_tin
  module_function :get_units
  module_function :get_excise_codes
end
