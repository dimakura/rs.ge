# -*- encoding : utf-8 -*-

module RS

  # ეს არის აქციზის კოდის აღმწერი კლასი.
  class ExciseCode
    # name -- აქციზის დასახელება
    # measure -- ზომის ერთეული
    # code -- აქციზის კოდი
    # value -- აქციზის განაკვეთი
    attr_accessor :id, :name, :measure, :code, :value
  end

  # ეს არის ზედნადების ტიპის კლასი.
  class WaybillType
    INNER = 1
    TRANSPORTATION = 2
    WITHOUT_TRANSPORTATION = 3
    DISTRIBUTION = 4
    RETURN = 5
    SUB_WAYBILL = 6
    NAMES = {
      1 => 'შიდა გადაზიდვა', 2 => 'ტრანსპორტირებით', 3 => 'ტრანსპორტირების გარეშე',
      4 => 'დისტრიბუცია', 5 => 'უკან დაბრუნება', 6 => 'ქვე-ზედნადები'
    }
    attr_accessor :id, :name
    def self.create_from_id(id)
      type = WaybillType.new
      type.id = id
      type.name = NAMES[id]
      type
    end
  end

  protected

  def normalize_excise_name(name)
    index = name =~ /\([0-9]+\)/
    index ? name[0..index-1].strip : name
  end

  public

  # აქციზის კოდების სიის მიღება.
  #
  # უნდა გადაეცეს შემდეგი პარამეტრები:
  #
  # su -- სერვისის მომხმარებლის სახელი
  # sp -- სერვისის მომხმარებლის პაროლი
  def self.get_excise_codes(params)
    RS.ensure_params(params, 'su', 'sp')
    client = RS.service_client
    response = client.request 'get_akciz_codes' do
      soap.body = params
    end
    codes_hash = response.to_hash[:get_akciz_codes_response][:get_akciz_codes_result][:akciz_codes][:akciz_code]
    codes = []
    codes_hash.each do |hash|
      code = ExciseCode.new
      code.id = hash[:id]
      code.name = normalize_excise_name(hash[:title])
      code.measure = hash[:measurement]
      code.code = hash[:sakon_kodi]
      code.value = hash[:akcis_ganakv].to_f
      codes << code
    end
    codes
  end

  # ზედნადების ტიპების მიღება.
  #
  # უნდა გადაეცეს შემდეგი პარამეტრები:
  #
  # su -- სერვისის მომხმარებლის სახელი
  # sp -- სერვისის მომხმარებლის პაროლი
  def self.get_waybill_types(params)
    RS.ensure_params(params, 'su', 'sp')
    client = RS.service_client
    response = client.request 'get_waybill_types' do
      soap.body = params
    end
    types_hash = response.to_hash[:get_waybill_types_response][:get_waybill_types_result][:waybill_types][:waybill_type]
    types = []
    types_hash.each do |hash|
      type = WaybillType.new
      type.id = hash[:id]
      type.name = hash[:name]
      #puts "#{type.id}: #{type.name}"
      types << type
    end
    types
  end

end
