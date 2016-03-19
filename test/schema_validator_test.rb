require_relative 'test_helper'
require 'awesome_print'

class ValidatorTest < Test::Unit::TestCase
  def setup
    @validator = Validator.new
  end

  test "#initialize" do
    validator = Validator.new([Integer, String])
    assert validator.valid?([1, "Mike"])
  end

  data(
    "noraml class" => ["String",    String],
    "module class" => ["Net::HTTP", Net::HTTP]
  )
  test "#get_class_from_string" do |data|
    expected, target = data
    assert_equal @validator.get_class_from_string(expected), target
  end

  sub_test_case "when set @schema" do
    test "builds schema from string value" do
      @validator.schema = {
        id:   "Integer",
        name: "String",
        prop: {
          class:  "Net::HTTP",
          url:  "URI.regexp"
        }
      }
      assert @validator.schema[:id]   == Integer
      assert @validator.schema[:name] == String
      assert @validator.schema[:prop][:class]  == Net::HTTP
      assert @validator.schema[:prop][:url]  == URI.regexp
    end

    test "builds schema from class value" do
      @validator.schema = {
        id:   Integer,
        name: String,
        prop: {
          class:  Net::HTTP,
          url:  URI.regexp
        }
      }
      assert @validator.schema[:id]   == Integer
      assert @validator.schema[:name] == String
      assert @validator.schema[:prop][:class]  == Net::HTTP
      assert @validator.schema[:prop][:url]  == URI.regexp

      @validator.schema = [Integer, String,]
      assert @validator.schema[0]   == Integer
      assert @validator.schema[1] == String
    end

    test "reset schema" do
      @validator.schema = { name: String, id: Integer }
      @validator.schema = { date: Date }
      assert_nil @validator.schema[:name]
      assert_nil @validator.schema[:id]
      assert @validator.schema[:date]
    end
  end

  sub_test_case "#load_yaml" do
    test "build schema" do
      @validator.load_yaml(File.expand_path('./test/fixtures/schema.yml'))
      assert @validator.schema["name"] == String
      assert @validator.schema["prop"]["class"]  == Net::HTTP
      assert @validator.schema["prop"]["url"]  == URI.regexp
    end

    test "build regexp" do
      @validator.load_yaml(File.expand_path('./test/fixtures/regexp_schema.yml'))
      assert @validator.schema["pascal_case"] == /^([A-Z][a-z]*)*$/
      assert @validator.valid?("pascal_case" => "CamelCase")
      assert_false @validator.valid?("pascal_case" => "pascalcase")
    end
  end

  sub_test_case "#valid?" do
    data(
      "one element"    => [ Integer, 1 ],
      "one deep array" => [ [Integer, String], [1, "Mike"] ],
      "two deep array" => [ [Integer, [String, String]], [1, ["Mike", "Jane"]] ],
      "hash"           => [ { id: Integer, name: String }, { id: 1, name: "Mike" } ]
    )
    test "returns true when validation is success" do |data|
      expected, target = data
      @validator.schema = expected
      assert @validator.valid?(target)
    end

    data(
      "one element"       => [ Integer, "1" ],
      "type"              => [ [Integer, String], [1, 2] ],
      "short one element" => [ [Integer], [1, 2] ],
      "hash is not array" => [ {id: Integer, name: String}, [Integer, String] ]
    )
    test "returns false when validation is failed" do |data|
      expected, target = data
      @validator.schema = expected
      assert_false @validator.valid?(target)
    end

    test "can use URI.regexp of string as regexp object" do
      @validator.schema = { url: "URI.regexp" }
      assert @validator.valid?({ url: "http://www.example.com" })
      assert_false @validator.valid?({ url: "www.example.com" })
    end

    test "can compare with regexp" do
      @validator.schema = { name: /[A-Z][a-z]/ }
      assert @validator.valid?({ name: "Mike" })
      assert_false @validator.valid?({ name: "mike" })
    end

    test "run block when validation is failed" do
      @validator.schema = { id: Integer }

      block_pass_flg = nil
      @validator.valid?(id: 1) { block_pass_flg = true }
      assert_nil block_pass_flg

      @validator.valid?(id: "1") do |target_value, schema|
        assert_equal target_value, "1"
        assert_equal schema, Integer
      end
    end
  end
end
