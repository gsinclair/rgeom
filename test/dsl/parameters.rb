  # Test some complex parameter matching.
D "DSL -> Parameters" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
    @segment = Segment.simple( p(4,5), p(-1,-1) )
  end

  D "lengths: [n,n]" do
    str = "lengths: [n,n]"
    parameter_set = ParameterSet.parse(str)
    parameter = parameter_set.parameters.first
    Eq parameter.match([4,92]),     [4,92]
    Eq parameter.match([4, 92, 1]), nil
    T parameter_set.generate_construction_spec(:lengths => [15,35])
  end

  D "angles: [a,a]" do
    str = "angles: [a,a]"
    parameter_set = ParameterSet.parse(str)
    parameter = parameter_set.parameters.first
    Eq parameter.match([4.d, 92.d]),       [4.d, 92.d]
    Eq parameter.match([4.d, 92.d, 1.d]),  nil
    Eq parameter.match([4.7.d, 1.65.r]),   [4.7.d, 1.65.r]
    T parameter_set.generate_construction_spec(:angles => [15.d,3.5.r])

    D "does not match [41, 37] because 41 and 37 are not Angles" do
      N parameter.match([41, 37])
      F parameter_set.generate_construction_spec(:angles => [41,37])
    end
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

  D "Direct type matching tests" do
    D "Type[:symbol]" do
      t = Type[:symbol]
      Eq t.match(:A), :A
    end
    D "Type[:angle]" do
      t = Type[:angle]
      Eq t.match(35.d), 35.d
      N  t.match(35)
    end
    D "Type[:length]" do
      t = Type[:length]
      s = seg p(1,3), p(0,0)
      Eq t.match(17.1), 17.1
      Ft t.match(s), 3.16227766
      N  t.match("a length of some sort...")
    end
    # Could test all sorts of things here...
  end

end  # "DSL -> Parameters"

