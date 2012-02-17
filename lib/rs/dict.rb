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
      code.name = hash[:title]
      code.measure = hash[:measurement]
      code.code = hash[:sakon_kodi]
      code.value = hash[:akcis_ganakv].to_f
      codes << code
    end
    codes
  end

end
