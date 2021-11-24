module BeValid
  require 'validators/date_validator'
  require 'validators/must_be_validator'

  def self.config
    @@config ||= Configuration.new
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config)
  end

  class Configuration
    attr_accessor :rules

    def initialize
      @rules = {}
    end
  end
end
