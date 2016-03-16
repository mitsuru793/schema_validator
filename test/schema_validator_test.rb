require_relative 'test_helper'
require 'awesome_print'

class ValidatorTest < Test::Unit::TestCase
  def setup
    @validator = Validator.new
  end
  test "#get_class_from_string" do
    true_pattern = [
      ["String",    String],
      ["Net::HTTP", Net::HTTP]
    ]
    true_pattern.each do |v|
      assert_equal @validator.get_class_from_string(v[0]), v[1]
    end
  end

  test "build schema when set to @schema" do
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

  test "build schema when load yaml" do
    @validator.load_yaml(File.expand_path('./test/fixtures/schema.yml'))
    assert @validator.schema["name"] == String
    assert @validator.schema["prop"]["class"]  == Net::HTTP
    assert @validator.schema["prop"]["url"]  == URI.regexp
  end

  test "reset schema when set" do
    @validator.schema = { name: String, id: Integer }
    @validator.schema = { date: Date }
    assert_nil @validator.schema[:name]
    assert_nil @validator.schema[:id]
    assert @validator.schema[:date]
  end

  test "#valid?" do
    true_pattern = [
      [ [Integer, String], [1, "Mike"] ],
      [ [Integer, [String, String]], [1, ["Mike", "Jane"]] ],
      [ { id: Integer, name: String }, { id: 1, name: "Mike" } ],
      [ [Integer, [String, String]], [1, ["Mike", "Jane"]] ]
    ]
    true_pattern.each do |v|
      @validator.schema = v[0]
      assert @validator.valid?(v[1])
    end

    false_pattern = [
      [ [Integer, String], [1, 2] ],
      [ [Integer], [1, 2] ]
    ]

    false_pattern.each do |v|
      @validator.schema = v[0]
      assert_false @validator.valid?(v[1])
    end

    @validator.schema = { url: "URI.regexp" }
    assert @validator.valid?({ url: "http://www.example.com" })
    assert_false @validator.valid?({ url: "www.example.com" })

    @validator.schema = { name: /[A-Z][a-z]/ }
    assert @validator.valid?({ name: "Mike" })
    assert_false @validator.valid?({ name: "mike" })
  end

  test "#initialize" do
    validator = Validator.new([Integer, String])
    assert validator.valid?([1, "Mike"])
  end
end
