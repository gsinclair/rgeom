require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

class TestSquare < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(7,-2)
    debug $test_unit_current_test
  end

  # square :ABCD   where A and B are defined
  # square :ABCD   where A is defined (or defaults to origin)
  # square :AB__   where A and B are defined
  # square :ABCD, :side => 10   where A is defined (or defaults to origin)
  # square :base => :CX

  def test_1_default_square
    square(:MNOP).tap do |s|
      assert_square s, %w(0 0   5 0   5 5   0 5)
      assert_point p(0,0), @register[:M]
      assert_point p(5,0), @register[:N]
      assert_point p(5,5), @register[:O]
      assert_point p(0,5), @register[:P]
      assert_equal 5, s.side
    end
  end

  def test_2a_default_square_off_origin
    square(:A___).tap do |s|
      assert_square s, %w(3 1   8 1   8 6   3 6)
      assert_point p(3,1), @register[:A]   # Sanity check.
      assert_equal 5, s.side
    end
  end

  def test_2b_default_square_off_origin_with_given_side
    square(:A___, :side => 1.5).tap do |s|
      assert_square s, %w(3 1   4.5 1   4.5 2.5   3 2.5)
      assert_equal 1.5, s.side
    end
  end

  def test_3a_angled_square_A_and_B_defined
    square(:AB__).tap do |s|
      assert_square s, %w(3 1   7 -2   10 2   6 7)
      assert_equal 5, s.side
    end
  end

  def test_3b_angled_square_A_and_B_defined
    square(:base => :AB).tap do |s|
      assert_square s, %w(3 1   7 -2   10 2   6 7)
      assert_equal 5, s.side
    end
  end

  def test_4a_angled_square_other_way_around
    square(:BARF).tap do |s|
      assert_square s, %w(7 -2   3 1   0 -3   4 -6)
      assert_equal 5, s.side
      assert_point p(0,-3), @register[:R]
      assert_point p(4,-6), @register[:F]
    end
  end

  def test_4b_angled_square_other_way_around
    square(:base => :BA).tap do |s|
      assert_square s, %w(7 -2   3 1   0 -3   4 -6)
      assert_equal 5, s.side
    end
  end

end  # TestSquare
