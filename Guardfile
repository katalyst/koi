# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :test do
  watch(%r{^lib/(.+)\.rb$})     { "test" }
  watch(%r{^test/.+_test\.rb$})
  watch('test/test_helper.rb')  { "test" }

  # Rails example
  watch(%r{^test/dummy/app/models/(.+)\.rb$})                   { |m| "test/dummy/test/unit/#{m[1]}_test.rb" }
  watch(%r{^test/dummy/app/controllers/(.+)\.rb$})              { |m| "test/dummy/test/functional/#{m[1]}_test.rb" }
  watch(%r{^test/dummy/app/views/.+\.rb$})                      { "test/dummy/test/integration" }
  watch('test/dummy/app/controllers/application_controller.rb') { ["test/functional", "test/integration"] }
end
