# -*- encoding : utf-8 -*-

module RS

  # ამოწმებს თუ რამდენად სწორია პირადი ნომრის ჩანაწერი.
  # პირადი ნომერი უნდა შედგებოდს ზუსტად 11 ციფრისაგან.
  def self.is_valid_personal_tin(tin)
    tin =~ /^[0-9]{11}$/
  end

  # ეს არის ზედნადების ხაზი საქონლისთვის.
  class WaybillItem
    attr_accessor :id, :prod_name, :unit_id, :unit_name, :quantity, :price, :bar_code, :excise_id

    # აბრუნებს ამ ხაზის XML წარმოდგენას.
    # @param xml XML builder-ის კლასი
    def to_xml(xml)
      xml.GOODS do |b|
        b.ID (self.id ? self.id : 0)
        b.W_NAME self.prod_name
        b.UNIT_ID self.unit_id
        b.UNIT_TXT self.unit_name
        b.QUANTITY self.quantity
        b.PRICE self.price
        b.AMOUNT self.quantity * self.price
        b.BAR_CODE self.bar_code
        b.A_ID (self.excise_id ? self.excise_id : 0)
      end
    end

    def self.init_from_hash(hash)
      item = WaybillItem.new
      item.id = hash[:id]
      item.prod_name = hash[:w_name]
      item.unit_id = hash[:unit_id].to_i
      item.unit_name = hash[:unit_txt]
      item.quantity = hash[:quantity].to_f
      item.price = hash[:price].to_f
      item.bar_code = hash[:bar_code]
      item.excise_id = hash[:a_id] == '0' ? nil : hash[:a_id].to_i
      item
    end
  end

  # ეს არის ზედნადების კლასი.
  class Waybill
    TRANSPORTATION_PAID_BY_BUYER  = 1
    TRANSPORTATION_PAID_BY_SELLER = 2
    STATUS_DELETED = -1
    STATUS_SAVED   =  0
    STATUS_ACTIVE  =  1
    STATUS_CLOSED  =  2
    attr_accessor :id, :type, :status, :parent_id
    attr_accessor :seller_id # გამყიდველის უნიკალური კოდი
    attr_accessor :buyer_tin, :check_buyer_tin, :buyer_name
    attr_accessor :seller_info, :buyer_info # გამყიდველის/მყიდველის თანამდებობა, სახელი და გვარი
    attr_accessor :driver_tin, :check_driver_tin, :driver_name
    attr_accessor :start_address, :end_address
    attr_accessor :transportation_cost, :transportation_cost_payer, :transport_type_id, :transport_type_name, :car_number
    attr_accessor :comment
    attr_accessor :create_date, :start_date, :delivery_date, :activate_date
    attr_accessor :items
    attr_accessor :error_code

    def to_xml(xml)
      xml.WAYBILL do |b|
        b.GOODS_LIST do |g|
          (self.items || []).each do |item|
            item.to_xml g
          end
        end
        b.ID (self.id ? self.id : 0)
        b.TYPE self.type
        b.BUYER_TIN self.buyer_tin
        b.CHEK_BUYER_TIN (self.check_buyer_tin ? 1 : 0)
        b.BUYER_NAME self.buyer_name
        b.START_ADDRESS self.start_address
        b.END_ADDRESS self.end_address
        b.DRIVER_TIN self.driver_tin
        b.CHEK_DRIVER_TIN (self.check_driver_tin ? 1 : 0)
        b.DRIVER_NAME self.driver_name
        b.TRANSPORT_COAST (self.transportation_cost ? self.transportation_cost : 0)
        b.RECEPTION_INFO self.seller_info
        b.RECEIVER_INFO self.buyer_info
        b.DELIVERY_DATE (self.delivery_date ? self.delivery_date.strftime('%Y-%m-%dT%H:%M:%S') : '')
        b.STATUS self.status
        b.SELER_UN_ID self.seller_id
        b.PAR_ID (self.parent_id ? self.parent_id : '')
        b.CAR_NUMBER self.car_number
        b.BEGIN_DATE (self.start_date ? self.start_date.strftime('%Y-%m-%dT%H:%M:%S') : '')
        b.TRANS_COST_PAYER (self.transportation_cost_payer ? self.transportation_cost_payer : Waybill::TRANSPORTATION_PAID_BY_BUYER)
        b.TRANS_ID self.transport_type_id
        b.TRANS_TXT self.transport_type_name
        b.COMMENT self.comment
      end
    end

    def self.init_from_hash(hash)
      waybill = Waybill.new
      items_hash = hash[:goods_list][:goods]
      items_hash = [items_hash] if items_hash.instance_of? Hash
      waybill.items = []
      items_hash.each do |item_hash|
        waybill.items << WaybillItem.init_from_hash(item_hash)
      end
      waybill.id = hash[:id]
      waybill.type = hash[:type].to_i
      waybill.status = hash[:status].to_i
      waybill.seller_id = hash[:seler_un_id].to_i
      waybill.buyer_tin = hash[:buyer_tin]
      waybill.check_buyer_tin = hash[:chek_buyer_tin].to_i == 1
      waybill.buyer_name = hash[:buyer_name]
      waybill.seller_info = hash[:reception_info]
      waybill.buyer_info = hash[:receiver_info]
      waybill.driver_tin = hash[:driver_tin]
      waybill.check_driver_tin = hash[:chek_driver_tin].to_i == 1
      waybill.driver_name = hash[:driver_name]
      waybill.start_address = hash[:start_address]
      waybill.end_address = hash[:end_address]
      waybill.transportation_cost = hash[:transport_coast].to_f
      waybill.transportation_cost_payer = hash[:tran_cost_payer] ? hash[:tran_cost_payer].to_i : nil
      waybill.transport_type_id = hash[:trans_id].to_i
      waybill.transport_type_name = hash[:trans_txt]
      waybill.car_number = hash[:car_number]
      waybill.comment = hash[:comment]
      waybill.create_date = hash[:create_date]
      waybill.start_date = hash[:begin_date]
      waybill.delivery_date = hash[:close_date]
      waybill.activate_date = hash[:activate_date]
      waybill
    end

    # ამოწმებს ამ კლასს შემდეგი შეცდომების არსებობაზე:
    #
    # 1) მყიდველის TIN
    # 2) მყიდველის სახელი უნდა იყოს მითითებული თუ უცხოელია
    # 3) თუ საავტომობილო გადაზიდვაა
    #   3.1) ავტომობილის სახელმწიფო ნომერი უნდა იყოს მითითებული
    #   3.2) მძღოლის TIN უნდა იყოს სწორი
    #   3.3) მძღოლის სახელი უნდა იყოს მითითებული თუ უცხოელია
    # 4) თუ ტრანსპორტირების სახეობაა "სხვა", უნდა იყოს მითითებული ტრანსპორტირების სახელწოდებაც
    # 5) უნდა იყოს მითითებული საწყისი მისამართი
    # 6) უნდა იყოს მითითებული საბოლოო მისამართი
    # 7) ერთი საქონელი მაინც უნდა იყოს მითითებული
    # 8) ცალკეულ საქონელზე: იხ. {WaybillItem#validate}
    # 9) არ უნდა არსებობდეს საქონლის გამეორებული კოდები
    def validate
      # TODO:
    end
  end

  # ზედნადების შენახვის მეთოდი
  #
  # გადაეცემა:
  # waybill -- ზედნადები
  # params -- პარამეტრები
  #
  # პარამეტრების შემდეგი მნიშვნელობებია დასაშვები:
  # su -- სერვისის მომხმარებლის სახელი
  # sp -- სერვისის მომხმარებლის პაროლი
  #
  # ინახავს ამ ზედნადებს და განაახლებს მის მონაცემებს.
  def self.save_waybill(waybill, params)
    RS.validate_presence_of(params, 'su', 'sp')
    client = RS.waybill_service
    response = client.request 'save_waybill' do |soap|
      soap.body do |xml|
        xml.ins0 :su, params['su']
        xml.ins0 :sp, params['sp']
        xml.ins0 :waybill do |b|
          waybill.to_xml b
        end
      end
    end
    hash_results = response.to_hash[:save_waybill_response][:save_waybill_result][:result]
    if hash_results[:status].to_i == 0
      waybill.id = hash_results[:id].to_i
      waybill.error_code = 0
      items_hash = hash_results[:goods_list][:goods]
      items_hash = [items_hash] if items_hash.instance_of? Hash
      (0..items_hash.size-1).each do |i|
        waybill.items[i].id = items_hash[i][:id].to_i
        #waybill.items[i].error_code = items_hash[i][:error].to_i
      end
    else
      waybill.error_code = hash_results[:status].to_i
    end
  end

  # ზედნადების გამოტანა.
  #
  # გადაცემა შემდეგი პარამეტრები:
  # waybill_id -- ზედნადების ID
  # su -- სერვისის მომხმარებელი
  # sp -- სერვისის მომხმარებლის პაროლი
  def self.get_waybill(params)
    RS.validate_presence_of(params, 'waybill_id', 'su', 'sp')
    client = RS.waybill_service
    response = client.request 'get_waybill' do |soap|
      soap.body = params.merge({:order => ['su', 'sp', 'waybill_id']})
    end
    #puts response.to_hash[:get_waybill_response][:get_waybill_result][:waybill]
    Waybill.init_from_hash(response.to_hash[:get_waybill_response][:get_waybill_result][:waybill])
  end

  # ზედნადების აქტივაცია.
  #
  # გადაეცემა შემდეგი პარამეტრები:
  # waybill_id -- ზედნადების ID
  # su -- სერვისის მომხმარებელი
  # sp -- სერვისის მომხმარებლის პაროლი
  #
  # აბრუნებს ამ ზედნადების ID-ს
  def self.activate_waybill(params)
    RS.validate_presence_of(params, 'waybill_id', 'su', 'sp')
    client = RS.waybill_service
    response = client.request 'send_waybill' do |soap|
      soap.body = params.merge({:order => ['su', 'sp', 'waybill_id']})
    end
    #puts response.to_hash[:send_waybill_response][:send_waybill_result].to_i
    response.to_hash[:send_waybill_response][:send_waybill_result].to_i
  end

  # ზედნადების დახურვა.
  #
  # გადაეცემა შემდეგი პარამეტრები:
  # waybill_id -- ზედნადების ID
  # su -- სერვისის მომხმარებელი
  # sp -- სერვისის მომხმარებლის პაროლი
  #
  # აბრუნებს <code>true</code> თუ დაიხურა.
  def self.close_waybill(params)
    RS.validate_presence_of(params, 'waybill_id', 'su', 'sp')
    client = RS.waybill_service
    response = client.request 'close_waybill' do |soap|
      soap.body = params.merge({:order => ['su', 'sp', 'waybill_id']})
    end
    #puts response.to_hash
    response.to_hash[:close_waybill_response][:close_waybill_result].to_i == 1
  end

  # ზედნადების წაშლა.
  #
  # გადაეცემა შემდეგი პარამეტრები:
  # waybill_id -- ზედნადების ID
  # su -- სერვისის მომხმარებელი
  # sp -- სერვისის მომხმარებლის პაროლი
  #
  # აბრუნებს <code>true</code> თუ წაიშალა.
  def self.delete_waybill(params)
    RS.validate_presence_of(params, 'waybill_id', 'su', 'sp')
    client = RS.waybill_service
    response = client.request 'del_waybill' do |soap|
      soap.body = params.merge({:order => ['su', 'sp', 'waybill_id']})
    end
    #puts response.to_hash
    response.to_hash[:del_waybill_response][:del_waybill_result].to_i == 1
  end

end
