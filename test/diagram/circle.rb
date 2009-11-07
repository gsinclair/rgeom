require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom
include Math

class TestCircleDiagram < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    FileUtils.rm_f('out/circles.png')
  end

  def test_circles
    (0..30).each do |d|
      centre = Point[sqrt(d), sqrt(d)]
      radius = sqrt(2.2*d)
      circle(:centre => centre, :radius => radius)
    end
    render("out/circles.png")
    assert File.exist? 'out/circles.png'
  end

end if defined? Cairo  # class TestSpiralDiagram

