# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'coffeescript', :input => 'src', :output => 'lib', :bare => true
guard 'coffeescript', :input => 'test', :output => 'test', :bare => true

# This is an example with all options that you can specify for guard-process
guard 'process', :name => 'Docco', :command => 'docco src/sketch.coffee' do
  watch %r{src/.+\.coffee}
end

