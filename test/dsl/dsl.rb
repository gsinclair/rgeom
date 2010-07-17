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
D "DSL (using circles as a means of testing the DSL)" do
  #include RGeom::Shapes

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(0,1), :B => p(4,1), :X => p(2,0)
  end

  D "tests using circle _specification_" do
    D.< do
      @prop = ::RGeom::Shape::Circle.shape_properties
    end

    D "low-level" do
      # We test some of the low-level stuff in the circle spec.  It's not
      # appropriate to do this for every shape, but we might as well do it once.
      T @prop.label_valid_for_this_shape?(Label[:X])
    end

    D "given :radius => 5" do
      spec = @prop.generate_construction_spec([:radius => 5])
      N  spec.label
      Eq spec.radius, 5
      Eq spec.centre, Point[0,0]
      Eq spec.parameters, [:centre, :radius]
    end

    D "given label and :radius => :AB" do
      spec = @prop.generate_construction_spec([:X, {:radius => :AB}])
      Eq spec.label,      Label[:X]
      Eq spec.radius,     Segment.from_symbol(:AB)
      Eq spec.parameters, [:radius]
    end

    D "given label and :diameter => :AB" do
      spec = @prop.generate_construction_spec([:M, {:diameter => :AB}])
      Eq spec.label,      Label[:M]
      Eq spec.diameter,   Segment.from_symbol(:AB)
      Eq spec.parameters, [:diameter]
    end

    D "invalid label leads to error" do
      E(RGeom::Err::SpecificationError) do
        spec = @prop.generate_construction_spec([:XYZ, {:diameter => :AB}])
      end
      Mt Attest.exception.message, /invalid.*label/i
    end

    D "given centre and diameter" do
      spec = @prop.generate_construction_spec([:centre => p(4,3), :diameter => 9])
      N  spec.label
      Eq spec.centre,     p(4,3)
      Eq spec.diameter,   9
      Eq spec.parameters, [:centre, :diameter]
    end

    D "given centre and radius" do
      spec = @prop.generate_construction_spec([:centre => :A, :radius => :BX])
      N  spec.label
      Eq spec.centre,     p(0,1)
      Eq spec.radius,     Math.sqrt(5)
      Eq spec.parameters, [:centre, :radius]
    end

    D "given nothing (using default values)" do
      spec = @prop.generate_construction_spec([])
      N  spec.label
      Eq spec.centre,     p(0,0)
      Eq spec.radius,     1
      Eq spec.parameters, [:centre, :radius]
    end
  end  # "tests using circle _specification_"

  D "tests using actual Circle objects (via _circle method)" do
    D "given label, centre and radius 10" do
      c = _circle(:K, :centre => :A, :radius => 10)
      Eq c.label,  Label[:K]
      Eq c.centre, p(0,1)
      Eq c.radius, 10
    end

    D "given radius :AB" do
      c = _circle(:radius => :AB)
      N  c.label
      Eq c.centre, p(0,1)
      Eq c.radius, 4
    end

    D "given radius :BA" do
      c = _circle(:radius => :BA)
      N  c.label
      Eq c.centre, p(4,1)
      Eq c.radius, 4
    end

    D "given diameter :AB" do
      c = _circle(:diameter => :AB)
      N  c.label
      Eq c.centre, p(2,1)
      Eq c.radius, 2
      N  c.id
    end

    D "using circle instead of _circle (-> registers object)" do
      c = circle(:P, :diameter => :XB)
      Eq c.label,   Label[:P]
      Eq c.centre,  p(3,0.5)
      Eq c.radius,  Math.sqrt(5)/2
      Eq c.id,      :cir01
      Eq Circle[0], c
    end
  end  # "tests using actual Circle objects (via _circle method)"

end  # "DSL (using circles as a means of testing the DSL)"


