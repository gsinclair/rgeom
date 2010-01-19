require 'test/unit'
require 'rgeom'
include RGeom
include RGeom::Assertions

class TestTriangleConstructBasic < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    debug ''
  end

  def test_1_default_triangle
    triangle  = triangle(:ABC)
    assert_kind_of Triangle, triangle
      # Could use assert_vertices here, but will leave it for posterity.
    triangle.vertices.tap do |v|
      assert_equal 0, v[0].x
      assert_equal 0, v[0].y
      assert_equal 5, v[1].x
      assert_equal 0, v[1].y
      assert_close 1.93877551, v[2].x
      assert_close 2.99937520, v[2].y
    end
    assert_equal triangle, @register.by_label(:triangle, :ABC)
    debug 'NOW'
    assert_equal triangle, @register.by_label(:triangle, :BAC)
    assert_equal triangle, @register.by_label(:triangle, :ACB)
    assert_equal triangle, @register.by_label(:triangle, :CBA)
    assert_equal :tri01, triangle.id
    assert_equal :ABC, triangle.label
    assert_equal triangle, Triangle[0]
  end

  def test_2_all_three_points_defined
    points :A => p(1,1), :B => p(4,0), :C => p(4,4)
    triangle  = triangle(:ABC)
    triangle.vertices.tap do |v|
      assert_equal 1, v[0].x
      assert_equal 1, v[0].y
      assert_equal 4, v[1].x
      assert_equal 0, v[1].y
      assert_close 4, v[2].x
      assert_close 4, v[2].y
    end
    assert_equal triangle, @register.by_label(:triangle, :ABC)
# Exact label needed for match at the moment...
#   assert_equal triangle, @register.retrieve(:triangle, :ACB)
    assert_equal p(4,4), triangle.apex
  end

  def test_3_default_iscosceles
  end

  def test_4_default_equilateral
    triangle(:ABC, :equilateral).tap do |t|
      assert_vertices t, %w{A 0 0   B 5 0   C 2.5 4.330127}
    end
  end

  def test_5_default_scalene
    t = triangle(:ABC, :scalene, :height => 3)
    assert_vertices t, %w{A 0 0   B 5 0   C 1.5 3}
  end

  def test_6_default_right
    t1 = triangle(:ABC, :right_angle => :A)
    debug t1
    assert_vertices t1, %w{A 0 0    B 5 0    C 0 3.75}

    @register.clear!
    t2 = triangle(:ABC, :right_angle => :B)
    debug t2
    assert_vertices t2, %w{A 0 0    B 5 0    C 5 3.75}

    @register.clear!
    t3 = triangle(:ABC, :right_angle => :C)
    debug t3
    assert_vertices t3, %w{A 0 0    B 5 0    C 3.2 2.4}

    # Try it with anonymous vertices.
    @register.clear!
    t4 = triangle(:right_angle => :second)
    debug t4
    assert_vertices t4, %w{_ 0 0    _ 5 0    _ 5 3.75}
  end

end   # class TestTriangleConstructBasic

