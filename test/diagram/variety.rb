require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

  # Simple diagrams.  We don't confirm the correctness of them, just that
  # they can be created and therefore the relevant diagram-producing code is
  # at least somewhat correct.
class TestDiagramVariety < Test::Unit::TestCase

  FILENAME = "out/variety.png"

  TESTS = []
  TESTS << { :desc => "Triangle",   :code => "triangle" }
  TESTS << { :desc => "Circle",     :code => "circle" }
  TESTS << { :desc => "Arc",        :code => "arc(:angles => [3,189])" }
  TESTS << { :desc => "Semicircle", :code => "semicircle" }

  TESTS.each do |test|
    description = test[:desc].downcase
    define_method("test_#{description}") {
      filename = "out/variety-#{description}.png"
      FileUtils.rm_f filename
      RGeom::Register.instance.clear!
      debug test[:desc]
      debug test[:code]
      eval test[:code]
      render filename
      assert File.file?(filename)
    }
  end

  debug "TestDiagramVariety has the following methods:"
  debug (TestDiagramVariety.instance_methods - Object.instance_methods).
    sort.join(" ").indent(3)

end if defined? Cairo    # class TestDiagramVariety
