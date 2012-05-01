# -*- encoding : utf-8 -*-
module RS
  def self.valid_vehicle_number?(num)
    not not (num =~ /^[a-zA-Z]{3}[0-9]{3}$/)
  end
end
