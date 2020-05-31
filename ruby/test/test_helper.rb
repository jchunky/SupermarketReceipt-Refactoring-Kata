require "minitest/autorun"
require "minitest/reporters"
require "bigdecimal"
require "bigdecimal/util"

Minitest::Reporters.use!

pattern = File.join(File.dirname(__FILE__), "..", "lib", "**", "*.rb")
Dir[pattern].each { |filepath| require_relative filepath }
