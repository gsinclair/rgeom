require 'test/unit'
require 'rgeom'
require 'fileutils'
include RGeom::Assertions
include RGeom

class TestSpiralDiagram < Test::Unit::TestCase

  NTRIANGLES = 50
  FILENAME   = "out/spiral-#{NTRIANGLES}.png"

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    FileUtils.rm_f(FILENAME)
  end

  def test_spiral
    # construction code taken from test/construct/spiral.rb
    first = triangle(:right_angle => :first, :base => 3, :height => 1)
    Shape.generate(NTRIANGLES, first) do |tn|
      triangle(:base => tn.hypotenuse.reverse, :right_angle => :first, :height => 1)
    end
    render(FILENAME)
    assert File.exist? FILENAME
  end

end if defined? Cairo  # class TestSpiralDiagram
