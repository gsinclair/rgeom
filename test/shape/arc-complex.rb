require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

  # This class tests proper arc features.  See TestArcBasic for simple tests
  # (based on Circle).
class TestArcComplex < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
    #debug $test_unit_current_test
  end

  def test_01_180_degree_arc_flat_radius
    arc(:radius => :AB, :angles => [0,180]).tap do |a|
      assert_arc [3,1, 3, nil, 0,180], a
      assert_point p(6,1), a.start
      assert_point p(0,1), a.end
      assert_point p(3,4), a.interpolate(0.5)
      assert_point p(2.072949017, 3.853169549), a.interpolate(0.6)
      # ---
      assert_equal [0,180], a.angles
      assert_equal [0,180], a.relative_angles
      assert_equal [0,180], a.absolute_angles
      assert_equal 0,       a.angle_offset
      assert_equal 180,     a.centre_angle
      assert_equal [p(0,1),p(6,4)], a.bounding_box
    end
  end

    # Exactly the same as test_01, but using 'semicircle' to create the shape.
  def test_02_semicircle
    semicircle(:radius => :AB).tap do |a|
      assert_arc [3,1, 3, nil, 0,180], a
      assert_point p(6,1), a.start
      assert_point p(0,1), a.end
      assert_point p(3,4), a.interpolate(0.5)
      assert_point p(2.072949017, 3.853169549), a.interpolate(0.6)
      # ---
      assert_equal [0,180], a.angles
      assert_equal [0,180], a.relative_angles
      assert_equal [0,180], a.absolute_angles
      assert_equal 0,       a.angle_offset
      assert_equal 180,     a.centre_angle
      assert_equal [p(0,1),p(6,4)], a.bounding_box
    end
  end

  def test_03_unusual_angles
    arc(:angles => [310,195]).tap do |a|
      assert_equal [-50,195], a.angles
      assert_equal 245,       a.centre_angle
      assert_equal true,      a.contains?(0)
      assert_equal true,      a.contains?(90)
      assert_equal true,      a.contains?(180)
      assert_equal false,     a.contains?(270)
      assert_equal [p(-1,-0.766044431),p(1,1)], a.bounding_box
      assert_equal [-50,195], a.relative_angles
      assert_equal [-50,195], a.absolute_angles
      assert_equal p(0.9984746773,0.05521158186), a.interpolate(0.217)
      assert_equal p(0.6427876097,-0.766044431), a.start
      assert_equal p(-0.9659258263,-0.2588190451), a.end
    end
  end

  def test_04_semicircle_angled_diameter
    semicircle(:diameter => :AC).tap do |a|
      assert_equal [0,180], a.angles
      assert_equal [0,180], a.relative_angles
      assert_close 14.03624347, a.angle_offset
      offset = a.angle_offset
      assert_equal [0+offset,180+offset], a.absolute_angles
      assert_equal p(7,2), a.start
      assert_equal p(3,1), a.end
    end
  end

end  # class TestArcComplex

