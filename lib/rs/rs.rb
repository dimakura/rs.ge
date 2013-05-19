# -*- encoding : utf-8 -*-
module RS
  def valid_tin?(tin)
    not not (tin =~ /^[0-9]{9}$|^[0-9]{11}$/)
  end

  module_function :valid_tin?
end
