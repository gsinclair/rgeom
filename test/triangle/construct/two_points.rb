require 'test/unit'
require 'rgeom'
include RGeom
include RGeom::Assertions

  # This class tests the basic triangles (equilateral, simple isosceles, default
  # scalene) in a variety of orientations with (importantly) the two base points
  # defined.
  #
  # For a greater variety of triangles, using the various options like :sides
  # and :angles, see TestTriangleConstructVariousOptions.
class TestTriangleConstructTwoPointsDefined < Test::Unit::TestCase

  def setup
    debug ''
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(2,1), :B => p(7,3), :C => p(2,-5), :D => p(-3,-1), :E => p(-1,7)
  end

    # Creates and tests four equilateral triangles.
  def test_1_equilateral_triangles
    debug "test_1_equilateral_triangles"
      # First one written out, to demonstrate what it looks like.
    triangle = triangle(:AB_, :equilateral)
    assert_vertices triangle, %w{A 2 1   B 7 3  _ 2.76795 6.33013}
      # Rest done in a loop.
    input = [:AC_, :AD_, :AE_]
    output = [
      %w{A 2 1   C  2 -5     _   7.19615  -2.00000},
      %w{A 2 1   D -3 -1     _   1.23205  -4.33013},
      %w{A 2 1   E -1  7     _  -4.69615   1.40192},
    ]
    (0..2).each do |i|
      triangle = triangle(input[i], :equilateral)
      debug triangle
      assert_vertices triangle, output[i]
    end
  end

    # Same as test 1, but :BA_ instead of :AB_, which means the triangle will be
    # "upside down" compared to before.
  def test_1_equilateral_triangles_reverse
    debug "test_1_equilateral_triangles_reverse"
    input = [:BA_, :CA_, :DA_, :EA_]
    output = [
      %w{B  7  3   A 2 1     _    6.23205  -2.33013},
      %w{C  2 -5   A 2 1     _   -3.19615  -2.00000},
      %w{D -3 -1   A 2 1     _   -2.23205   4.33013},
      %w{E -1  7   A 2 1     _    5.69615   6.59808},
    ]
    (0..3).each do |i|
      triangle = triangle(input[i], :equilateral)
      assert_vertices triangle, output[i]
    end
  end

  def test_2_isosceles_triangles
    debug 'test_2_isosceles_triangles'
    input = [:AB_, :AC_, :AD_, :AE_]
    output = [
      %w{A 2 1   B  7  3     _   2.64305   6.64238},
      %w{A 2 1   C  2 -5     _   7.00000  -2.00000},
      %w{A 2 1   D -3 -1     _   1.35695  -4.64238},
      %w{A 2 1   E -1  7     _  -3.97214   1.76393},
    ]
    (0..3).each do |i|
      triangle = triangle(input[i], :isosceles, :height => 5)
      assert_vertices triangle, output[i]
    end
  end

  def test_2_isosceles_triangles_reverse
    debug 'test_2_isosceles_triangles_reverse'
    input = [:BA_, :CA_, :DA_, :EA_]
    output = [
      %w{B  7  3   A 2 1     _    6.35695  -2.64238},
      %w{C  2 -5   A 2 1     _   -3.00000  -2.00000},
      %w{D -3 -1   A 2 1     _   -2.35695   4.64238},
      %w{E -1  7   A 2 1     _    4.97214   6.23607},
    ]
    (0..3).each do |i|
      triangle = triangle(input[i], :isosceles, :height => 5)
      assert_vertices triangle, output[i]
    end
  end

    # Create and test four scalene (default 5,6,7) triangles.
  def test_3_scalene_triangles
    debug 'test_3_scalene_triangles'
    input = [:AB_, :AC_, :AD_, :AE_]
    output = [
      %w{A 2 1   B  7  3     _   2.73903   4.77489},
      %w{A 2 1   C  2 -5     _   5.59925  -1.32653},
      %w{A 2 1   D -3 -1     _   1.26097  -2.77489},
      %w{A 2 1   E -1  7     _  -2.76252   1.52691},
    ]
    (0..3).each do |i|
      triangle = triangle(input[i], :scalene)
      assert_vertices triangle, output[i]
    end
  end

    # Reverse of test 3.
  def test_3_scalene_triangles_reverse
    debug 'test_3_scalene_triangles_reverse'
    input = [:BA_, :CA_, :DA_, :EA_]
    output = [
      %w{B  7  3   A 2 1     _    6.26097  -0.77489},
      %w{C  2 -5   A 2 1     _   -1.59925  -2.67347},
      %w{D -3 -1   A 2 1     _   -2.26097   2.77489},
      %w{E -1  7   A 2 1     _    3.76252   6.47309},
    ]
    (0..3).each do |i|
      triangle = triangle(input[i], :scalene)
      assert_vertices triangle, output[i]
    end
  end

    # Use A(1,0) and B(7,0) for some easy testing.
  def test_4_test_right_triangles_basic
    debug 'test_4_test_right_triangles_basic'
    @register.clear!
    points :A => p(1,0), :B => p(7,0)
    tx = triangle(:ABX, :right_angle => :A, :height => 4)
    ty = triangle(:ABY, :right_angle => :B, :height => 4)
    tz = triangle(:ABZ, :right_angle => :Z, :height => 2)
    assert_point_equal p(1,4), tx.apex
    assert_point_equal p(7,4), ty.apex
    assert_point_equal p(1.764,2), tz.apex
  end

  def test_4_test_right_triangles_complex
    debug 'test_4_test_right_triangles_complex'
    t1 = triangle(:DE_, :right_angle => :D, :height => 9)
    assert_point_equal p(-11.73128,1.18282), t1.apex

    t2 = triangle(:ED_, :right_angle => :D, :height => 1)
    assert_point_equal p(-2.02986,-1.24254), t2.apex

    t3 = triangle(:DE_, :right_angle => :apex, :height => 3)
    debug t3
    assert_point_equal p(-5.5964218,0.98362951), t3.apex
  end

  #def test_5_sas_triangles
  #end

end  # class TestTriangleConstructTwoPointsDefined
