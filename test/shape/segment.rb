require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

class TestSegment < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(-2,-4.5)
  end

  def test_1_two_predefined_points
    s = segment(:AB).tap do |s|
      assert_equal p(3,1), s.p
      assert_equal p(-2,-4.5), s.q
      assert_close 7.433034374, s.length
      assert_close -2.308611387, s.angle
      debug @register
      assert_same s, @register.by_label(:segment, :AB)
      assert_same s, Segment[0]
    end
  end

  def test_2_start_and_end
    s = segment(:start => :B, :end => p(-4,-10)).tap do |s|
      assert_equal p(-2,-4.5), s.p
      assert_equal p(-2,-4.5), s.start
      assert_equal p(-4,-10), s.q
      assert_equal p(-4,-10), s.end
      assert_close 5.85234995535981, s.length
      assert_close -1.9195673303788, s.angle
      assert_same  s, Segment[0]
    end
  end

  def test_3_interpolate
    segment(:start => p(-5,5), :end => p(4,3)).tap do |s|
      assert_equal p(-5,5), s.p
      assert_equal p(4,3),  s.q
      assert_equal p(-5,5), s.interpolate(0)
      assert_equal p(-5,5), s.interp(0)
      assert_equal p(4,3),  s.interp(1)
      assert_equal p(6.7,2.4),   s.interp(1.3)
      assert_equal p(15.7,0.4),  s.interp(2.3)
      assert_equal p(-2.3,4.4),  s.interp(0.3)
      assert_equal p(-11.3,6.4), s.interp(-0.7)
    end
  end

  def test_4_extend
    segment(:AB).extend(2.1)
    assert_equal 2,                 @register.nobjects
    assert_equal p(-7.500,-10.550), Segment[1].q

    segment(:AB).extend(-1, :X)
    assert_equal p(8.0, 6.5), Segment[-1].q
    assert_equal p(8.0, 6.5), @register[:X]
    #assert_equal :AX,         Segment[-1].label
    # TODO: make the above line happen
  end

  def test_5_midpoint
    segment(:AB).tap do |s|
      assert_equal p(0.5,-1.75), s.midpoint
    end
  end

  def xtest_other_ways
    segments(:BE, :ED)
    segments(:BED)
    segments(:BE, :ED, :dotted)
    segments(:BED, :dotted)
  end

end  # TestSegment
