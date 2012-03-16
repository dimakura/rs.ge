# -*- encoding : utf-8 -*-

module RS

  # ქმნის ფაქტურას მოცემული ზედნადებისთვის.
  #
  # ზედნადებზე ფაქტურის გამოწერა ხდება მხოლოდ დახურულ მდგომარეობაში.
  def self.save_waybill_invoice(waybill, params = {})
    RS.validate_presence_of(params, 'su', 'sp')
    client = RS.waybill_service
    params2 = params.merge( 'waybill_id' => waybill.id, 'in_inv_id' => 0 )
    response = client.request 'save_invoice' do |soap|
      soap.body = params2
    end
    waybill.invoice_id = response[:save_invoice_response][:out_inv_id].to_i
  end

end
