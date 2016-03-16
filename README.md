# SchemaValidator

Arrayの各要素の型や、Hashのkey名とvalueの型などの構造を検証することができます。スキーマはArray、Hashで定義することができるので、スキーマファイルをYAMLなどの別ファイルで管理することが可能です。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'schema_validator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install schema_validator

## Usage

```ruby
schema = [Integer, String]
validator = Validator.new(schema)
validator.valid?([1, "Mike"])
# => true
validator.valid?([1, 2])
# => false

validator.schema = { id: Integer, name: String }
validator.valid?({ id: 1, name: "Mike" })
# => true
validator.valid?({ id: 1, first_name: "Mike" })
# => false

validator.schema = { name: /[A-Z][a-z]/ }
validator.valid?({ name: "Mike" })
# => true
validator.valid?({ name: "mike" })
# => false
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

