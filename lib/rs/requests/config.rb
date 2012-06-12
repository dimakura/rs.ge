# -*- encoding : utf-8 -*-
require 'singleton'

module RS

  # RS configuration.
  class Config
    include Singleton

    attr_accessor :sp, :su, :validate_remote
  end

  class << self
    def config
      RS::Config.instance
    end
  end

end