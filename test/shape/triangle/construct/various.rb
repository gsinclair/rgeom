require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

  # Tests triangles with various specifications (e.g. sides/angles/height).
  # The focus is simply on finding the correct apex; other test cases have
  # covered the basics of the Triangle and Register class adequately.
class TestTriangleConstructVarious < Test::Unit::TestCase
  def setup
    debug ''
    @register = RGeom::Register.instance
    @register.clear!
    points :M => p(-3,-7), :K => p(4,0), :C => p(5,-2)
  end

  def test_base_and_angles_with_one_point
    triangle = triangle(:MAT, :base => 10, :angles => [15.d, 10.d])
    assert_point_equal p(0.96886, -5.93655), triangle.apex
  end

  def test_base_and_angles_with_two_points
    triangle = triangle(:CK_, :angles => [33.d, 40.d])
    assert_point_equal p(3.7041144689,-1.2386455559), triangle.apex
  end

  def test_three_sides
    triangle = triangle(:PQR, :sides => [5,8,7])
    assert_point_equal p(1.000000, 6.92820), triangle.apex
    assert_point_equal p(0,0), @register[:P]
    assert_point_equal p(5,0), @register[:Q]
    assert_point_equal p(1.000000, 6.92820), @register[:R]
  end

  def test_scalene_base_height_simple
    triangle = triangle(:PQR, :scalene, :base => 11, :height => 8)
    assert_point_equal p(0,0), @register[:P]
    assert_point_equal p(11,0), @register[:Q]
    assert_point_equal p(3.3,8), @register[:R]
  end

  def test_scalene_base_height_complex
    triangle = triangle(:MK_, :scalene, :height => 4)
    assert_point_equal p(-3.728427,-2.071573), triangle.apex
  end

  def test_right_various
    @register.clear!
    points :A => p(0,1), :B => p(7,0)
    tx = triangle(:ABX, :right_angle => :A, :height => 3)
    ty = triangle(:ABY, :right_angle => :B, :height => 3)
    tz = triangle(:ABZ, :right_angle => :Z, :height => 3)
    assert_point_equal p(0.424264,3.969848), tx.apex
    assert_point_equal p(7.424264,2.969848), ty.apex
    assert_point_equal p(2.072238,3.734424), tz.apex
  end

  def test_base_arrow_AB
    t = triangle(:equilateral, :base => :KC)
    assert_point_equal p(6.23205,-0.13397), t.apex
  end

  def test_base_arrow_k_comma_c
    k = @register[:K]
    c = @register[:C]
    t = triangle(:equilateral, :base => [k,c])
    assert_point_equal p(6.23205,-0.13397), t.apex
  end

end  # class TestTriangleConstructVarious

