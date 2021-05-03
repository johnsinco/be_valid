module BeValid
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
