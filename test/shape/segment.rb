D "Segment" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(-2,-4.5)
  end

  D "construct" do
    D.< do
      @register.clear!
      points :A => p(3,1), :B => p(-2,-4.5)
    end

    D ":AB" do
      s = segment(:AB).tap do |s|
        Eq s.p,      p(3,1)
        Eq s.q,      p(-2,-4.5)
        Ft s.length, 7.433034374
        Ft s.angle,  -2.308611387
        Id s,        @register.by_label(:segment, :AB)
        Id s,        Segment[0]
      end
    end

    D ":start => :B, :end => p(-4,-10)" do
      s = segment(:start => :B, :end => p(-4,-10)).tap do |s|
        Eq s.p,      p(-2,-4.5)
        Eq s.start,  p(-2,-4.5)
        Eq s.q,      p(-4,-10)
        Eq s.end,    p(-4,-10)
        Ft s.length, 5.85234995535981
        Ft s.angle,  -1.9195673303788
        Id s,        Segment[0]
      end
    end
  end

  D "interpolate" do
    segment(:start => p(-5,5), :end => p(4,3)).tap do |s|
      Eq s.p,              p(-5,5)
      Eq s.q,              p(4,3)
      Eq s.interpolate(0), p(-5,5)
      Eq s.interp(0),      p(-5,5)
      Eq s.interp(1),      p(4,3)
      Eq s.interp(1.3),    p(6.7,2.4)
      Eq s.interp(2.3),    p(15.7,0.4)
      Eq s.interp(0.3),    p(-2.3,4.4)
      Eq s.interp(-0.7),   p(-11.3,6.4)
    end
  end

  D "extend" do
    segment(:AB).extend(2.1)
    Eq @register.nobjects, 2
    Eq Segment[1].q,       p(-7.500,-10.550)

    segment(:AB).extend(-1, :X)
    Eq Segment[-1].q, p(8.0, 6.5)
    Eq @register[:X], p(8.0, 6.5)
    # Eq Segment[-1].label, :AX
    # TODO: make the above line happen
  end

  D "midpoint" do
    segment(:AB).tap do |s|
      Eq s.midpoint, p(0.5,-1.75)
    end
  end

  ## def xtest_other_ways
  ##   segments(:BE, :ED)
  ##   segments(:BED)
  ##   segments(:BE, :ED, :dotted)
  ##   segments(:BED, :dotted)
  ## end

end  # "Segment"
