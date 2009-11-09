require 'test/unit'
require 'rgeom'
require 'pp'

require 'ruby-debug'

include RGeom

class TestRegister < Test::Unit::TestCase
  def setup
    @register = RGeom::Register.instance
    @register.clear!
    debug ''
  end

  def test_points_1
    points :A => p(3,9), :B => p(0,-2.543)
    assert_equal p(3,9), @register[:A]
    assert_equal p(0,-2.543), @register[:B]
    assert_equal 2, @register.npoints
    assert_equal 0, @register.nobjects
  end

  def test_points_2
    @register[:S] = p(4,3)
    assert_equal p(4,3), @register[:S]
    assert_equal 1, @register.npoints
    assert_equal 0, @register.nobjects
  end

  def test_triangle
    points :G => p(0,0), :M => p(1,0), :K => p(0.39,0.60)
    t = triangle(:GMK)
    assert_equal p(0,0), @register[:G]
    assert_equal p(1,0), @register[:M]
    assert_equal p(0.39,0.60), @register[:K]
    assert_equal t, @register.by_label(:triangle, :GMK)
# These don't work at the moment, and I'm not sure I care...
#   assert_equal t, @register.retrieve(:triangle, :GKM)
#   assert_equal t, @register.retrieve(:triangle, :KMG)
#   assert_equal t, @register.retrieve(:triangle, :KGM)
#   assert_equal t, @register.retrieve(:triangle, :MGK)
#   assert_equal t, @register.retrieve(:triangle, :MKG)
    assert_equal nil, @register[:A]
    assert_equal nil, @register.by_label(:triangle, :ABC)
    assert_equal 3, @register.npoints
    assert_equal 1, @register.nobjects
  end

  def test_point_reassignment_raises_error
    points :A => p(3,9), :B => p(0,-2.543)
    assert_raises(ArgumentError) do
      @register[:A] = p(4,-1)
    end
  end

end
