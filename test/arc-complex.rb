require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

  # This class tests proper arc features.  See TestArcBasic for simple tests
  # (based on Circle).
class TestArc < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
    #debug $test_unit_current_test
  end

  def test_01
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
  def test_02
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

  def test_03
    arc(:angles => [310,195]).tap do |a|
      assert_equal [-50,195], a.angles
      assert_equal 245,       a.centre_angle
      assert_equal true,      a.contains?(0)
      assert_equal true,      a.contains?(90)
      assert_equal true,      a.contains?(180)
      assert_equal false,     a.contains?(270)
    end
  end

end  # class TestArc

