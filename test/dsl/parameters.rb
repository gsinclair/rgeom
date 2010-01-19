require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

  # Test some complex parameter matching.
class TestParameters < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
    @segment = Segment.simple( p(4,5), p(-1,-1) )
  end

  def test_01_array_type
    str = "angles: [n,n]"
    parameter_set = ParameterSet.parse(str)
    parameter = parameter_set.parameters.first
    assert_equal [4,92], parameter.match([4,92])
    assert parameter_set.generate_construction_spec(:angles => [15,35])
  end

  def test_02_two_defaults_and_array_type
    str = "centre: point=origin, radius: length=1, angles: [n,n]"
    parameter_set = ParameterSet.parse(str)
    assert parameter_set.generate_construction_spec(:centre => :A, :radius => 5, :angles => [10, 20])
    assert parameter_set.generate_construction_spec(:radius => 5, :angles => [10, 20])
    assert parameter_set.generate_construction_spec(:centre => :A, :angles => [10, 20])
    assert parameter_set.generate_construction_spec(:angles => [10, 20])
  end

  def test_03_buried_default
    str = "base: (segment,n=nil)"
    parameter_set = ParameterSet.parse(str)
    assert parameter_set.generate_construction_spec(:base => :AB)
    assert parameter_set.generate_construction_spec(:base => @segment)
    assert parameter_set.generate_construction_spec(:base => 5)
    assert parameter_set.generate_construction_spec({})
  end

  def test_04_complex
    str = "base: (segment,n=nil), right_angle: symbol, height: length=nil, slant: symbol=nil"
    parameter_set = ParameterSet.parse(str)
    assert parameter_set.generate_construction_spec(:right_angle => :A)
  end

  def test_05_symbol_type
    t = Type[:symbol]
    #debugger
    t.match(:A)
    assert_equal :A, t.match(:A)
  end

end  # class TestParameters

