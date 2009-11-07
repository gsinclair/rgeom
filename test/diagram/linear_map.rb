require 'test/unit'
require 'rgeom'
include RGeom::Assertions

class TestLinearMap < Test::Unit::TestCase

  LinearMap = RGeom::Diagram::Canvas::LinearMap

  def assert_map(map, values={})
    values.each_pair do |x, x_|
      assert_close x_, map.map(x)
    end
  end

  def debug_map(map, range)
    range.each do |i|
      debug [i, map.map(i)].inspect
    end
  end

  def test_1
    map = LinearMap.new(1..10, 5..14)
    assert_map map, 1 => 5, 2 => 6, 3 => 7, 4 => 8, 5 => 9,
                    6 => 10, 7 => 11, 8 => 12, 9 => 13, 10 => 14
  end

  def test_2
    map = LinearMap.new(0..10, 0..20)
    assert_map map, 0 => 0, 10 => 20, 3 => 6, 5 => 10, 9.4 => 18.8
  end

  def test_3
    map = LinearMap.new(5..7, 83..100)
    assert_map map, 5 => 83, 7 => 100
    assert_map map, 0 => 40.5
    assert_map map, 5.27 => 85.295, 6.1928 => 93.1388
  end

  def test_4
    map = LinearMap.new(0..100, 100..0)
    assert_map map, 0 => 100, 100 => 0
    assert_map map, 10 => 90, 25 => 75, 50 => 50, 75 => 25, 90 => 10
    assert_map map, 13.935 => 86.065
  end

  def test_5
    map = LinearMap.new(4.2..-1.7, 0..928)
    assert_map map, 4.2 => 0, -1.7 => 928
    assert_map map, 2.5 => 267.3898305
  end

end  # class TestLinearMap
