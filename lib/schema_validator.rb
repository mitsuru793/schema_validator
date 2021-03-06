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

    def valid?(target_value, schema=@schema, &block)
      case target_value
        when Hash
          target_value.all? { |k, v| valid?(v, schema[k], &block) }
        when Array
          target_value.all? { |v| valid?(v, schema[target_value.index(v)], &block) }
        else
          if schema === target_value
            true
          else
            yield(target_value, schema) if block_given?
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
      else
        @schema = schema
      end
    end

    def change_schema_value(schema, index, value)
      if Enumerable === value
        schema[index] = build_schema(value)
      else
        case value
        when "URI.regexp"
          schema[index] = @uri_re
        when String
          if /\/.*\//.match(value)
            schema[index] = Regexp.new(value[1..-2])
          else
            schema[index] = get_class_from_string(value)
          end
        else
          schema[index] = value
        end
      end
    end
  end
end
