# The code tested here is internal RGeom code, not part of the public API.

D "DSL -> Construction spec" do
  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
  end

  D "thorough test of ConstructionSpec object" do
    D.< do
      @spec = ConstructionSpec.new({:base => 5, :angle => 13})
      @spec.parameters      = [:base, :angle]
      @spec.fixed_parameter = :type
      @spec.fixed_argument  = :isosceles
      @spec.label           = :JKL
    end

    D "basic properties (label, parameters)" do
      Eq @spec.label, :JKL
      Eq @spec.parameters, [:base, :angle]
    end

    D "fixed_parameter and fixed_argument combine correctly" do
      Eq @spec.type, :isosceles
    end

    D "dynamic properties (like OpenStruct)" do
      Eq @spec.base, 5
      Eq @spec.angle, 13
      Eq @spec.height, nil
      Eq @spec.fajsdfafsdajsdkalfh, nil
    end
  end  # "thorough test of ConstructionSpec object"

  D "'sans' method" do
    arc_spec = ConstructionSpec.new({:centre => :A, :radius => 5, :angles => [45, 100]})
    arc_spec.parameters = [:centre, :radius, :angles]
    arc_spec.label      = :K

    circle_spec = arc_spec.sans(:angles)

    Eq circle_spec.parameters, [:centre, :radius]
    Eq circle_spec.label,      :K
    Eq circle_spec.centre,     :A
    Eq circle_spec.radius,     5
    Eq circle_spec.angles,     nil
  end

end  # "DSL -> Construction spec"
