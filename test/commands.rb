require 'test/unit'
require 'rgeom'

include RGeom
include RGeom::Assertions

class TestCommands < Test::Unit::TestCase
  def setup
    @register = RGeom::Register.instance
    @register.clear!
    points :G => [-3,0.5], :H => [0,1]
  end

  def test_points_1
    assert_kind_of Point, pt(5,5)
    assert_kind_of Point, p(5,5)
    assert_equal   9,     pt(9,4).x
    assert_equal   4,     pt(9,4).y
  end

  def test_points_2
    assert_kind_of Point, pt(:G)
    assert_kind_of Point, p(:G)
    assert_equal   -3,    pt(:G).x
    assert_equal   0.5,   p(:G).y
  end

  def test_points_3
    p1 = Point[5,2]
    assert_kind_of Point, pt(p1)
    assert_kind_of Point, p(p1)
    assert_equal   5,     pt(p1).x
    assert_equal   2,     pt(p1).y
  end

  def test_points_4
    assert_equal nil, p(nil)
  end

  def test_segments
    assert_kind_of Segment, seg(:GH)
    assert_kind_of Segment, s(:GH)
    assert_point   p(:G),   seg(:GH).p
    assert_point   p(:H),   seg(:GH).q
    assert_kind_of Segment, seg( p(4,2), p(7,-1) )
    assert_kind_of Segment, s( p(4,2), p(7,-1) )
    assert_point   p(4,2),  seg( p(4,2), p(7,-1) ).p
    assert_point   p(7,-1), seg( p(4,2), p(7,-1) ).q
    assert_equal   nil,     seg(nil)
    assert_equal   nil,     s(nil)
    assert_kind_of Segment, seg( seg(:GH) )
    assert_kind_of Segment, s( seg(:GH) )
    assert_point   p(:G),   seg( seg(:GH) ).p
    assert_point   p(:H),   seg( seg(:GH) ).q
    assert_point   p(:G),   seg( seg( seg( seg(:GH) ) ) ).p
    assert_point   p(:H),   seg( seg( seg( seg(:GH) ) ) ).q
  end

end  # class TestCommands
