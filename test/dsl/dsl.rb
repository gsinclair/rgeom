require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom::Shapes
include RGeom

#
# Basic test of the DSL: can it load?
# If and when more complex DSL tests are written, this could be renamed
# TestDSLBasic or something.
#
# Using the 'circle' spec because that was used to motivate development.  For
# reference, here it is:
#
#   shape :circle, :label => :K,
#     :parameters => %{
#       centre: point=origin, radius: length=1
#       centre: point=origin, diameter: length
#       radius: segment
#       diameter: segment
#     }
#
class TestDSL < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(0,1), :B => p(4,1), :X => p(2,0)
    @prop = ::RGeom::Shape::Circle.shape_properties
  end

  def test_circle_spec_1
    # We test some of the low-level stuff in the circle spec.  It's not
    # appropriate to do this for every shape, but we might as well do it once.
    debug @prop.instance_variable_get(:@parameters).pp_s
    assert @prop.label_valid_for_this_shape?(Label[:X])
  end

  def test_circle_spec_2
    spec = @prop.generate_construction_spec([:radius => 5])
    assert_equal nil, spec.label
    assert_equal 5,   spec.radius
    assert_equal Point[0,0], spec.centre
    assert_equal [:centre, :radius], spec.parameters
  end

  def test_circle_spec_3
    spec = @prop.generate_construction_spec([:X, {:radius => :AB}])
    assert_not_nil spec
    assert_equal Label[:X], spec.label
    assert_equal Segment.from_symbol(:AB), spec.radius
    assert_equal [:radius], spec.parameters
  end

  def test_circle_spec_3
    spec = @prop.generate_construction_spec([:M, {:diameter => :AB}])
    assert_not_nil spec
    assert_equal Label[:M], spec.label
    assert_equal Segment.from_symbol(:AB), spec.diameter
    assert_equal [:diameter], spec.parameters
  end

  def test_circle_spec_4
    assert_raises(RGeom::Err::SpecificationError) do
      spec = @prop.generate_construction_spec([:XYZ, {:diameter => :AB}])
    end
  end

  def test_circle_spec_5
    spec = @prop.generate_construction_spec([:centre => p(4,3), :diameter => 9])
    assert_not_nil spec
    assert_equal nil, spec.label
    assert_equal p(4,3), spec.centre
    assert_equal 9, spec.diameter
    assert_equal [:centre, :diameter], spec.parameters
  end

  def test_circle_spec_6
    spec = @prop.generate_construction_spec([:centre => :A, :radius => :BX])
    assert_not_nil spec
    assert_equal nil, spec.label
    assert_equal p(0,1), spec.centre
    assert_equal Math.sqrt(5), spec.radius
    assert_equal [:centre, :radius], spec.parameters
  end

  def test_circle_spec_7
    spec = @prop.generate_construction_spec([])  # totally default
    assert_not_nil spec
    assert_equal nil, spec.label
    assert_equal p(0,0), spec.centre
    assert_equal 1, spec.radius
    assert_equal [:centre, :radius], spec.parameters
  end

  def test_circle_create_1
    c = _circle(:K, :centre => :A, :radius => 10)
    assert_equal Label[:K], c.label 
    assert_equal p(0,1),    c.centre 
    assert_equal 10,        c.radius 
  end

  def test_circle_create_2
    c = _circle(:radius => :AB)
    assert_equal nil,    c.label 
    assert_equal p(0,1), c.centre 
    assert_equal 4,      c.radius 
  end

  def test_circle_create_3
    c = _circle(:radius => :BA)
    assert_equal nil,    c.label 
    assert_equal p(4,1), c.centre 
    assert_equal 4,      c.radius 
  end

  def test_circle_create_4
    c = _circle(:diameter => :AB)
    assert_equal nil,    c.label 
    assert_equal p(2,1), c.centre 
    assert_equal 2,      c.radius 
    assert_nil           c.id
  end

  def test_circle_create_and_register_1
    c = circle(:P, :diameter => :XB)
    assert_equal Label[:P],      c.label 
    assert_equal p(3,0.5),       c.centre 
    assert_equal Math.sqrt(5)/2, c.radius 
    assert_equal :cir01,         c.id
    assert_equal c, Circle[0]
  end

end  # TestDSL

