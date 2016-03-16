Dir[File.join(File.dirname(__FILE__), "../lib/**/*.rb")].each { |f| require f }
require 'test/unit'
include SchemaValidator
