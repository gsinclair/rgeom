require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

class TestCircle < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
    #debug $test_unit_current_test
  end

  def test_01
    circle().tap do |c|
      assert_circle [0,0, 1, nil], c
      assert_equal :circle, c.category
      assert_equal :cir01,  c.id
      assert_equal nil,     c.label
    end
  end

  def test_02
    circle(:G, :centre => p(5,2)).tap do |c|
      assert_circle [5,2, 1, :G], c
      assert_equal :circle, c.category
      assert_equal :cir01,  c.id
      assert_equal :G,      c.label.symbol
    end
  end

  def test_03
    circle(:G, :centre => p(5,2), :radius => 3).tap do |c|
      assert_circle [5,2, 3, :G], c
    end
  end

  def test_04
    circle(:G, :radius => 9).tap do |c|
      assert_circle [0,0, 9, :G], c
    end
  end

  def test_05
    circle(:centre => :A).tap do |c|
      assert_circle [3,1, 1, nil], c
    end
  end

  def test_06
    circle(:centre => :A, :radius => 4).tap do |c|
      assert_circle [3,1, 4, nil], c
    end
  end

  def test_07
    circle(:centre => :A, :diameter => 4).tap do |c|
      assert_circle [3,1, 2, nil], c
    end
  end

  def test_08
    circle(:centre => :A, :radius => :BC).tap do |c|
      assert_circle [3,1, Math.sqrt(2), nil], c
    end
  end

  def test_09
    circle(:centre => :A, :diameter => :BC).tap do |c|
      assert_circle [3,1, Math.sqrt(2)/2, nil], c
      # Gotta test these methods once!
      assert_equal p(3,1), c.centroid
      r = c.radius
      assert_equal [p(3-r,1-r), p(3+r,1+r)], c.bounding_box
      assert_equal [p(3,1)], c.points   # A circle's only 'point' is its centre.
    end
  end

  def test_10
    circle(:radius => :AB).tap do |c|
      assert_circle [3,1, 3, nil], c
    end
  end

  def test_11
    circle(:radius => :BA).tap do |c|
      assert_circle [6,1, 3, nil], c
    end
  end

  def test_12
    circle(:diameter => :AB).tap do |c|
      assert_circle [4.5,1, 1.5, nil], c
    end
  end

  def test_13
    circle(:diameter => :BA).tap do |c|
      assert_circle [4.5,1, 1.5, nil], c
    end
  end

  def test_14
    circle(:M, :centre => p(7,-2), :radius => :AC).tap do |c|
      assert_circle [7,-2, Math.sqrt(17), :M], c
    end
  end

  def test_15
    circle(:X, :centre => p(3,-9), :diameter => :AC).tap do |c|
      assert_circle [3,-9, Math.sqrt(17)/2, :X], c
      assert_equal :circle, c.category
      assert_equal :cir01,  c.id
      assert_equal :X,      c.label.symbol
    end
  end

    # This is really a test of Register, but nevermind.
  def test_16_consecutive_ids
    c1 = circle()
    c2 = circle(:centre => p(5,6), :radius => 7)
    assert_equal :cir01,  c1.id
    assert_equal :cir02,  c2.id
    assert_equal c1, @register.by_id(:cir01)
    assert_equal c2, @register.by_id(:cir02)
    assert_equal c1, Circle[0]
    assert_equal c2, Circle[1]
    assert_equal c2, Circle[-1]
  end

  alias ar assert_raise
  SE = RGeom::Err::SpecificationError
  def test_17_invalid_specs
    ar(SE) { circle(:centre => :F) }
    ar(SE) { circle(:radius => :DF) }
    ar(SE) { circle(:radius => :DFG) }
    ar(SE) { circle(:radius => 4, :diameter => 7) }
    ar(SE) { circle(:centre => "centre") }
    ar(SE) { circle(:centre => :AB) }
  end

end  # TestCircle
