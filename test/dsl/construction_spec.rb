require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

  # Test some complex parameter matching.
class TestConstructionSpec < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
  end

  def test_01_thorough
    spec = ConstructionSpec.new({:base => 5, :angle => 13})
    spec.parameters      = [:base, :angle]
    spec.fixed_parameter = :type
    spec.fixed_argument  = :isosceles
    spec.label           = :JKL

    assert_equal :JKL,            spec.label
    assert_equal :isosceles,      spec.type
    assert_equal [:base, :angle], spec.parameters
    assert_equal 5,    spec.base
    assert_equal 13,   spec.angle
    assert_equal nil,  spec.height
    assert_equal nil,  spec.fajsdfafsdajsdkalfh
  end

  def test_02_sans
    arc_spec = ConstructionSpec.new({:centre => :A, :radius => 5, :angles => [45, 100]})
    arc_spec.parameters = [:centre, :radius, :angles]
    arc_spec.label      = :K
    circle_spec = arc_spec.sans(:angles)
    assert_equal [:centre, :radius], circle_spec.parameters
    assert_equal :K,                 circle_spec.label
    assert_equal :A,                 circle_spec.centre
    assert_equal 5,                  circle_spec.radius
    assert_equal nil,                circle_spec.angles
  end

end  # class TestConstructionSpec


