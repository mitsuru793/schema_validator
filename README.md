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

### Array/Hashの値に文字列を指定した場合
YAMLでスキーマを簡単に定義できるように、valueの文字列は特殊扱いされます。

基本、クラス名として扱われます。クラス名の一文字は大文字にして下さい。

```yaml
# ○
- Integer
- String
id: Integer
name: String

# ☓
- integer
name: string
```

モジュールにある定数を指定することもできます。

```yaml
url: Net::HTTP
```

正規表現を使う場合は前後に/（スラッシュ）を入れて下さい。正規表現オブジェクトに変換されます。

```yaml
full-name: /[A-Z][a-z]* [A-Z][a-z]*/
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

