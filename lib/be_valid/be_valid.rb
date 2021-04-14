module BeValid
  def self.config
    @@config ||= Configuration.new
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config)
  end

  class Configuration
    attr_accessor :notice_rules

    def initialize
      @notice_rules= []
    end
  end
end
