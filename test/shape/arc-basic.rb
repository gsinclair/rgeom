require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

  # TestArcBasic is adapted test-for-test from TestCircle, because of the similarity
  # of the two classes (Arc defers to Circle for much of its implementation).
  # See TestArc for more thorough testing of arc-specific features.
class TestArcBasic < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
    #debug $test_unit_current_test
  end

  def test_01
    arc(:angles => [5,7]).tap do |a|
      assert_arc   [0,0, 1, nil, 5,7], a
      assert_equal :arc,    a.category
      assert_equal :arc01,  a.id
      assert_equal nil,     a.label
    end
  end

  def test_02
    arc(:G, :centre => p(5,2), :angles => [5,7]).tap do |a|
      assert_arc   [5,2, 1, :G, 5,7], a
      assert_equal :arc,    a.category
      assert_equal :arc01,  a.id
      assert_equal :G,      a.label.symbol
    end
  end

  def test_03
    arc(:G, :centre => p(5,2), :radius => 3, :angles => [5,7]).tap do |a|
      assert_arc   [5,2, 3, :G, 5,7], a
    end
  end

  def test_04
    arc(:G, :radius => 9, :angles => [5,7]).tap do |a|
      assert_arc   [0,0, 9, :G, 5,7], a
    end
  end

  def test_05
    arc(:centre => :A, :angles => [5,7]).tap do |a|
      assert_arc   [3,1, 1, nil, 5,7], a
    end
  end

  def test_06
    arc(:centre => :A, :radius => 4, :angles => [5,7]).tap do |a|
      assert_arc   [3,1, 4, nil, 5,7], a
    end
  end

  def test_07
    arc(:centre => :A, :diameter => 4, :angles => [5,7]).tap do |a|
      assert_arc   [3,1, 2, nil, 5,7], a
    end
  end

  def test_08
    arc(:centre => :A, :radius => :BC, :angles => [5,7]).tap do |a|
      assert_arc   [3,1, Math.sqrt(2), nil, 5,7], a
    end
  end

  def test_09
    arc(:centre => :A, :diameter => :BC, :angles => [5,7]).tap do |a|
      assert_arc   [3,1, Math.sqrt(2)/2, nil, 5,7], a
      # Gotta test these methods once!
      assert_equal nil, a.centroid
      assert_equal [p(3,1)], a.points   # An arc's only 'point' is its centre.
    end
  end

  def test_10
    arc(:radius => :AB, :angles => [5,7]).tap do |a|
      assert_arc   [3,1, 3, nil, 5,7], a
    end
  end

  def test_11
    arc(:radius => :BA, :angles => [5,7]).tap do |a|
      assert_arc   [6,1, 3, nil, 5,7], a
    end
  end

  def test_12
    arc(:diameter => :AB, :angles => [5,7]).tap do |a|
      assert_arc   [4.5,1, 1.5, nil, 5,7], a
    end
  end

  def test_13
    arc(:diameter => :BA, :angles => [5,7]).tap do |a|
      assert_arc   [4.5,1, 1.5, nil, 5,7], a
    end
  end

  def test_14
    arc(:M, :centre => p(7,-2), :radius => :AC, :angles => [5,7]).tap do |a|
      assert_arc   [7,-2, Math.sqrt(17), :M, 5,7], a
    end
  end

  def test_15
    arc(:X, :centre => p(3,-9), :diameter => :AC, :angles => [5,7]).tap do |a|
      assert_arc   [3,-9, Math.sqrt(17)/2, :X, 5,7], a
      assert_equal :arc,    a.category
      assert_equal :arc01,  a.id
      assert_equal :X,      a.label.symbol
    end
  end

    # This is really a test of Register, but nevermind.
  def test_16_consecutive_ids
    a1 = arc(:angles => [5,7])
    a2 = arc(:centre => p(5,6), :radius => 7, :angles => [5,7])
    assert_equal :arc01,  a1.id
    assert_equal :arc02,  a2.id
    assert_equal a1, @register.by_id(:arc01)
    assert_equal a2, @register.by_id(:arc02)
    assert_equal a1, Arc[0]
    assert_equal a2, Arc[1]
    assert_equal a2, Arc[-1]
  end

  alias ar assert_raise
  SE = RGeom::Err::SpecificationError
  def test_17_invalid_specs
    ar(SE) { arc(:centre => :F, :angles => [40,50]) }
    ar(SE) { arc(:radius => :DF, :angles => [40,50]) }
    ar(SE) { arc(:radius => :DFG, :angles => [40,50]) }
    ar(SE) { arc(:radius => 4, :diameter => 7, :angles => [40,50]) }
    ar(SE) { arc(:centre => "centre", :angles => [40,50]) }
    ar(SE) { arc(:centre => :AB, :angles => [40,50]) }
    ar(SE) { arc(:centre => p(5,2), :radius => 7) }
  end

end  # TestArc
