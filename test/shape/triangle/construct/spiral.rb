require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

  # Create a spiral of triangles, each built on the last.
class TestTriangleConstructSpiral < Test::Unit::TestCase

  def setup
    debug ''
    @register = RGeom::Register.instance
    @register.clear!
  end

    # This is a spiral with three right-angled triangles, using named vertices
    # all the way.
  def test_spiral_1
    triangle(:ABC, :right_angle => :A, :base => 3, :height => 1)
    triangle(:CBD, :right_angle => :C, :height => 1)
    triangle(:DBE, :right_angle => :D, :height => 1)
    b = @register[:B]
    e = @register[:E]
    assert_close Math.sqrt(12), Point.distance(b, e)
  end

    # This is a spiral with 10 right-angled triangles, using mostly anonymous vertices.
    # test_spiral_3 is a better way of coding this.
  def test_spiral_2
    arr = []
    arr << triangle(:ABC, :right_angle => :A, :base => 3, :height => 1)
    9.times do
      p1 = arr.last.apex
      p2 = @register[:B]
      arr << triangle(:base => [p1,p2], :right_angle => :first, :height => 1)
    end
    b = @register[:B]
    x = arr.last.apex
    assert_close Math.sqrt(19), Point.distance(b, x), 0.000000001
  end

    # This does the same as test_spiral_2, but uses Shape.generate and Triangle#hypotenuse.
  def test_spiral_3
    first = triangle(:right_angle => :first, :base => 3, :height => 1)
    Shape.generate(10, first) do |tn|
      triangle(:base => tn.hypotenuse.reverse, :right_angle => :first, :height => 1)
    end
    assert_close Math.sqrt(19), Triangle[-1].hypotenuse.length
    assert_equal 10, @register.nobjects
      # ^ We're checking that only the 11 triangles end up in the register, not
      #   any extraneous segments (i.e. the hypotenuses).
  end

end  # TestTriangleConstructSpiral
