require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

pattern = File.join(File.dirname(__FILE__), "..", "lib", "**", "*.rb")
Dir[pattern].each { |filepath| require_relative filepath }

require_relative "./fake_catalog"
