D "Circle" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
  end

  D "default -- centre p(0,0), radius 1" do
    circle().tap do |c|
      T :circle, c, [0,0, 1, nil]
      Eq c.category, :circle
      Eq c.id,       :cir01
      Eq c.label,    nil
    end
  end

  D "given label, centre p(5,2)" do
    circle(:G, :centre => p(5,2)).tap do |c|
      T :circle, c, [5,2, 1, :G]
      Eq c.category,     :circle
      Eq c.id,           :cir01
      Eq c.label.symbol, :G
    end
  end

  D "given label, centre p(5,2), radius 3" do
    circle(:G, :centre => p(5,2), :radius => 3).tap do |c|
      T :circle, c, [5,2, 3, :G]
    end
  end

  D "given label, radius 9" do
    circle(:G, :radius => 9).tap do |c|
      T :circle, c, [0,0, 9, :G]
    end
  end

  D "given centre :A" do
    circle(:centre => :A).tap do |c|
      T :circle, c, [3,1, 1, nil]
    end
  end

  D "given centre :A, radius 4" do
    circle(:centre => :A, :radius => 4).tap do |c|
      T :circle, c, [3,1, 4, nil]
    end
  end

  D "given centre :A, diameter 4" do
    circle(:centre => :A, :diameter => 4).tap do |c|
      T :circle, c, [3,1, 2, nil]
    end
  end

  D "given centre :A, radius :BC" do
    circle(:centre => :A, :radius => :BC).tap do |c|
      T :circle, c, [3,1, Math.sqrt(2), nil]
    end
  end

  D "given centre :A, diameter :BC" do
    circle(:centre => :A, :diameter => :BC).tap do |c|
      T :circle, c, [3,1, Math.sqrt(2)/2, nil]
      # Gotta test these methods once!
      Eq c.centroid, p(3,1)
      r = c.radius
      Eq c.bounding_box, [p(3-r,1-r), p(3+r,1+r)]
      Eq c.points, [p(3,1)]    # A circle's only 'point' is its centre.
    end
  end

  D "given radius :AB" do
    circle(:radius => :AB).tap do |c|
      T :circle, c, [3,1, 3, nil]
    end
  end

  D "given radius :BA" do
    circle(:radius => :BA).tap do |c|
      T :circle, c, [6,1, 3, nil]
    end
  end

  D "given diameter :AB" do
    circle(:diameter => :AB).tap do |c|
      T :circle, c, [4.5,1, 1.5, nil]
    end
  end

  D "given diameter :BA" do
    circle(:diameter => :BA).tap do |c|
      T :circle, c, [4.5,1, 1.5, nil]
    end
  end

  D "given label, centre p(-7,-2), radius :AC" do
    circle(:M, :centre => p(7,-2), :radius => :AC).tap do |c|
      T :circle, c, [7,-2, Math.sqrt(17), :M]
    end
  end

  D "given label, centre p(3,-9), diameter :AC" do
    circle(:X, :centre => p(3,-9), :diameter => :AC).tap do |c|
      T :circle, c, [3,-9, Math.sqrt(17)/2, :X]
      Eq c.category,     :circle
      Eq c.id,           :cir01
      Eq c.label.symbol, :X
    end
  end

    # This is really a test of Register, but nevermind.
  D "#id, @register.by_id, Circle[n]" do
    c1 = circle()
    c2 = circle(:centre => p(5,6), :radius => 7)
    Eq c1.id, :cir01
    Eq c2.id, :cir02
    Eq @register.by_id(:cir01), c1
    Eq @register.by_id(:cir02), c2
    Eq Circle[0],  c1
    Eq Circle[1],  c2
    Eq Circle[-1], c2
  end

  SE = RGeom::Err::SpecificationError
  D "invalid specifications --> error" do
    E(SE) { circle(:centre => :F) }
    E(SE) { circle(:radius => :DF) }
    E(SE) { circle(:radius => :DFG) }
    E(SE) { circle(:radius => 4, :diameter => 7) }
    E(SE) { circle(:centre => "centre") }
    E(SE) { circle(:centre => :AB) }
  end

end  # "Circle"
