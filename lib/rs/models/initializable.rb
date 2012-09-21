module RS::Initializable
  def initialize(opts = {})
    opts.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
end