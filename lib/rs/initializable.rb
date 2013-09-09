# -*- encoding : utf-8 -*-
module RS
  class Initializable
    def initialize(opts = {})
      opts.each do |k, v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
  end
end
