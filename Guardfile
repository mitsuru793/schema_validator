guard :test, cmd: "bundle exec test" do
  # Test files
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "test/lib/#{m[1]}_test.rb" }
  watch('test/test_helper.rb') { "test" }
end