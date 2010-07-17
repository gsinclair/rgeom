  # Test some complex parameter matching.
D "DSL -> Parameters" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
    @segment = Segment.simple( p(4,5), p(-1,-1) )
  end

  D "angles: [n,n]" do
    str = "angles: [n,n]"
    parameter_set = ParameterSet.parse(str)
    parameter = parameter_set.parameters.first
    Eq parameter.match([4,92]),     [4,92]
    Eq parameter.match([4, 92, 1]), nil
    T parameter_set.generate_construction_spec(:angles => [15,35])
  end

  D "centre: point=origin, radius: length=1, angles: [n,n]" do
    str = "centre: point=origin, radius: length=1, angles: [n,n]"
    parameter_set = ParameterSet.parse(str)
    T parameter_set.generate_construction_spec(:centre => :A, :radius => 5, :angles => [10, 20])
    T parameter_set.generate_construction_spec(:radius => 5, :angles => [10, 20])
    T parameter_set.generate_construction_spec(:centre => :A, :angles => [10, 20])
    T parameter_set.generate_construction_spec(:angles => [10, 20])
  end

  D "base: (segment,n=nil)" do
    str = "base: (segment,n=nil)"
    parameter_set = ParameterSet.parse(str)
    T parameter_set.generate_construction_spec(:base => :AB)
    T parameter_set.generate_construction_spec(:base => @segment)
    T parameter_set.generate_construction_spec(:base => 5)
    T parameter_set.generate_construction_spec({})
  end

  D "base: (segment,n=nil), right_angle: symbol, height: length=nil, slant: symbol=nil" do
    str = "base: (segment,n=nil), right_angle: symbol, height: length=nil, slant: symbol=nil"
    parameter_set = ParameterSet.parse(str)
    T parameter_set.generate_construction_spec(:right_angle => :A)
  end

  D "Type[:symbol]" do
    t = Type[:symbol]
    Eq t.match(:A), :A
  end

end  # "DSL -> Parameters"

