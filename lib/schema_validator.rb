require "schema_validator/version"
require 'yaml'
require 'uri'

module SchemaValidator
  class Validator
    attr_reader :schema, :uri_re

    def initialize(schema=nil)
      @uri_re = URI.regexp
      @schema = schema
    end

    def schema=(schema_hash)
      @schema = build_schema(schema_hash)
    end

    def load_yaml(path)
      schema_hash = YAML.load_file(path)
      @schema = build_schema(schema_hash)
    end

    def valid?(target, schema=@schema)
      case target
        when Hash
          target.all? { |k, v| valid?(v, schema[k]) }
        when Array
          target.all? { |v| valid?(v, schema[target.index(v)]) }
        else
          if schema === target
            true
          else
            puts "#{target} is not #{schema}"
            false
          end
      end
    end

    def get_class_from_string(class_name)
      class_name.split("::").reduce(Object, :const_get)
    end

    private
    def build_schema(schema)
      case schema
      when Hash
        schema.each do |k, v|
          change_schema_value(schema, k, v)
        end
      when Array
        schema.each_with_index do |v, i|
          change_schema_value(schema, i, v)
        end
      end
    end

    def change_schema_value(schema, index, value)
      if Enumerable === value
        schema[index] = build_schema(value)
      else
        if value == "URI.regexp"
          schema[index] = @uri_re
        else
          schema[index] = String === value ? get_class_from_string(value) : value
        end
      end
    end
  end
end
