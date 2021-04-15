$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

# courtesy https://github.com/fnando/validators
require "bundler/setup"
require "minitest/autorun"
require "active_record"
require "active_support/all"
require "be_valid"


ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
load "schema.rb"


class User < ActiveRecord::Base
  def self.name
    "User"
  end

  def status
    name == 'beyonce' ? OpenStruct.new(:'premium?' => true) : OpenStruct.new(:'premium?' => false)
  end
end

module CleanDB
  def after_setup 
    super
    ActiveRecord::Base.descendants.each do |model|
      next if %w[ActiveRecord::InternalMetadata ActiveRecord::SchemaMigration primary::SchemaMigration].include?(model.name)

      model.delete_all

      Object.class_eval do
        remove_const model.name if const_defined?(model.name)
      end
    end
  end
end

class MiniTest::Unit::TestCase
    include CleanDB
end
