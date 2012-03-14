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
      INNER => 'შიდა გადაზიდვა', TRANSPORTATION => 'ტრანსპორტირებით', WITHOUT_TRANSPORTATION => 'ტრანსპორტირების გარეშე',
      DISTRIBUTION => 'დისტრიბუცია', RETURN => 'უკან დაბრუნება', SUB_WAYBILL => 'ქვე-ზედნადები'
    }
    attr_accessor :id, :name
    def self.create_from_id(id)
      type = WaybillType.new
      type.id = id
      type.name = NAMES[id]
      type
    end
    def self.all_types
      []
    end
  end

  # ზედნადების ერთეულების განსაზღვრა.
  class WaybillUnit
    attr_accessor :id, :name

    # ეს კოდი შეესაბამება ზომის ერთეულს 'სხვა'.
    OTHERS = 99
  end

  # ტრანსპორტირების ტიპი
  class TransportType
    VEHICLE = 1
    RAILWAY = 2
    AIR     = 3
    OTHERS  = 4
    NAMES   = { VEHICLE => 'საავტომობილო', RAILWAY => 'სარკინიგზო', AIR => 'საავიაციო', OTHERS => 'სხვა' }

    attr_accessor :id, :name

    def self.create_from_id(id)
      type = TransportType.new
      type.id = id
      type.name = NAMES[id]
      type
    end
  end

  # შტრიხკოდის აღმწერი კლასი
  class BarCode
    attr_accessor :code, :name, :unit_id, :unit_name, :excise_id
  end

  protected

  def self.normalize_excise_name(name)
    index = name =~ /\([0-9]*\)/
    index ? name[0..index-1].strip : name
  end

  public

  # აქციზის კოდების სიის მიღება.
  #
  # უნდა გადაეცეს შემდეგი პარამეტრები:
  #
  # su -- სერვისის მომხმარებლის სახელი
  # sp -- სერვისის მომხმარებლის პაროლი
  # normilize -- კი/არა, გამოიყენოს თუ არა სახელების ნორმალიზებული მნიშვნელობები (საწყისად ნორმალიზებულია)
  def self.get_excise_codes(params)
    RS.ensure_open_user(params)
    RS.validate_presence_of(params, 'su', 'sp')
    client = RS.waybill_service
    response = client.request 'get_akciz_codes' do
      soap.body = params
    end
    normalize = params['normilize'] || true
    codes_hash = response.to_hash[:get_akciz_codes_response][:get_akciz_codes_result][:akciz_codes][:akciz_code]
    codes = []
    codes_hash.each do |hash|
      code = ExciseCode.new
      code.id = hash[:id]
      code.name = normalize ? normalize_excise_name(hash[:title]) : hash([:title])
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
    RS.ensure_open_user(params)
    RS.validate_presence_of(params, 'su', 'sp')
    client = RS.waybill_service
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

  # ზედნადების ზომის ერთეულების მიღება.
  #
  # უნდა გადაეცეს შემდეგი პარამეტრები:
  #
  # su -- სერვისის მომხმარებლის სახელი
  # sp -- სერვისის მომხმარებლის პაროლი
  def self.get_waybill_units(params)
    RS.ensure_open_user(params)
    RS.validate_presence_of(params, 'su', 'sp')
    client = RS.waybill_service
    response = client.request 'get_waybill_units' do
      soap.body = params
    end
    units_hash = response.to_hash[:get_waybill_units_response][:get_waybill_units_result][:waybill_units][:waybill_unit]
    units = []
    units_hash.each do |hash|
      unit = WaybillUnit.new
      unit.id = hash[:id]
      unit.name = hash[:name]
      #puts "#{unit.id}: #{unit.name}"
      units << unit
    end
    units
  end

  # ტრანსპორტის სახეობების მიღება.
  #
  # უნდა გადაეცეს შემდეგი პარამეტრები:
  #
  # su -- სერვისის მომხმარებლის სახელი
  # sp -- სერვისის მომხმარებლის პაროლი
  def self.get_transport_types(params)
    RS.ensure_open_user(params)
    RS.validate_presence_of(params, 'su', 'sp')
    client = RS.waybill_service
    response = client.request 'get_trans_types' do
      soap.body = params
    end
    types_hash = response.to_hash[:get_trans_types_response][:get_trans_types_result][:transport_types][:transport_type]
    types = []
    types_hash.each do |hash|
      type = TransportType.new
      type.id = hash[:id]
      type.name = hash[:name]
      #puts "#{type.id}: #{type.name}"
      types << type
    end
    types
  end

  # შტრიხკოდის შენახვის მეთოდი.
  #
  # უნდა გადაეცეს შემდეგი პარამეტრები:
  #
  # su -- სერვისის მომხმარებლის სახელი
  # sp -- სერვისის მომხმარებლის პაროლი
  # bar_code -- შტრიხკოდის მნიშვნელობა
  # prod_name -- საქონლის დასახელება (შეესაბამება <code>goods_name</code> RS-ის სპეციფიკაციაში)
  # unit_id -- ზომის ერთეულის კოდი
  # unit_name -- ზომის ერთეულის დასახელება, როდესაც #{unit_id} ტოლია #{WaybillUnit::OTHERS},
  #   სხვა მნიშვნელობისთვის ეს პარამეტრი არ უნდა გადმოეცეს
  #   (შეესანამება <code>unit_txt</code> პარამეტრს RS-ის სპეციფიკაციაში)
  # excise_id -- აქციზის კოდი. ან <code>nil</code>, თუ აქციზის კოდი არ უყენდება ამ საქონელს
  #   (შეესაბამება <code>a_id</code> პარამეტრს RS-ის სპეციფიკაციაში)
  def self.save_bar_code(params)
    RS.validate_presence_of(params, 'su', 'sp', 'bar_code', 'prod_name', 'unit_id')
    params2 = {'su' => params['su'], 'sp' => params['sp'], 'bar_code' => params['bar_code'],
      'goods_name' => params['prod_name'], 'unit_id' => params['unit_id'],
      'unit_txt' => params['unit_name'], 'a_id' => params['excise_id']}
    prepare_params(params2)
    params2['order!'] = ['su', 'sp', 'bar_code', 'goods_name', 'unit_id', 'unit_txt', 'a_id']
    client = RS.waybill_service
    response = client.request 'save_bar_code' do
      soap.body = params2
    end
    resp = response.to_hash[:save_bar_code_response][:save_bar_code_result]
    resp.to_i == 1 # success!
  end

  # შტრიხკოდის წაშლის მეთოდი.
  #
  # უნდა გადაეცეს შემდეგი პარამეტრები:
  #
  # su -- სერვისის მომხმარებლის სახელი
  # sp -- სერვისის მომხმარებლის პაროლი
  # bar_code -- შტრიხკოდის მნიშვნელობა
  def self.delete_bar_code(params)
    RS.validate_presence_of(params, 'su', 'sp', 'bar_code')
    params['order!'] = ['su', 'sp', 'bar_code']
    client = RS.waybill_service
    response = client.request 'delete_bar_code' do
      soap.body = params
    end
    resp = response.to_hash[:delete_bar_code_response][:delete_bar_code_result]
    resp.to_i == 1 # success!
  end

  # შტრიხკოდების მიღების მეთოდი.
  #
  # უნდა გადაეცეს შემდეგი პარამეტრები:
  #
  # su -- სერვისის მომხმარებლის სახელი
  # sp -- სერვისის მომხმარებლის პაროლი
  # bar_code -- შტრიხკოდის მნიშვნელობა, რომლის მსგავსის ამოღებაც გვინდა
  def self.get_bar_codes(params)
    RS.validate_presence_of(params, 'su', 'sp', 'bar_code')
    params['order!']= ['su', 'sp', 'bar_code']
    client = RS.waybill_service
    response = client.request 'get_bar_codes' do
      soap.body = params
    end
    codes_hash = response.to_hash[:get_bar_codes_response][:bar_codes][:bar_codes][:bar_code]
    codes_hash = [codes_hash] if codes_hash.instance_of? Hash
    codes = []
    codes_hash.each do |hash|
      code = BarCode.new
      code.code = hash[:code]
      code.name = hash[:name]
      code.unit_id = hash[:unit_id].to_i
      code.unit_name = hash[:unit_txt]
      code.excise_id = hash[:a_id].to_i == 0 ? nil : hash[:a_id].to_i
      codes << code
    end
    codes
  end

end
