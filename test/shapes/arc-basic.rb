
  # TestArcBasic is adapted test-for-test from TestCircle, because of the similarity
  # of the two classes (Arc defers to Circle for much of its implementation).
  # See TestArc for more thorough testing of arc-specific features.
D "Arc (basic)" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
  end

  D "default -- centre p(0,0), radius 1 -- angles [5.d,7.d]" do
    arc(:angles => [5.d,7.d]).tap do |a|
      T :arc, a, [0,0, 1, nil, 5.d,7.d]
      Eq a.category, :arc
      Eq a.id,       :arc01
      Eq a.label,    nil
    end
  end

  D "given label, centre p(5,2), angles [5.d,7.d]" do
    arc(:G, :centre => p(5,2), :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [5,2, 1, :G, 5.d,7.d]
      Eq a.category,     :arc
      Eq a.id,           :arc01
      Eq a.label.symbol, :G
    end
  end

  D "given label, centre p(5,2), radius 3, angles [5.d,7.d]" do
    arc(:G, :centre => p(5,2), :radius => 3, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [5,2, 3, :G, 5.d,7.d]
    end
  end

  D "given label, radius 9, angles [5.d,7.d]" do
    arc(:G, :radius => 9, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [0,0, 9, :G, 5.d,7.d]
    end
  end

  D "given centre :A, angles [5.d,7.d]" do
    arc(:centre => :A, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [3,1, 1, nil, 5.d,7.d]
    end
  end

  D "given centre :A, radius 4, angles [5.d,7.d]" do
    arc(:centre => :A, :radius => 4, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [3,1, 4, nil, 5.d,7.d]
    end
  end

  D "given centre :A, diameter 4, angles [5.d,7.d]" do
    arc(:centre => :A, :diameter => 4, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [3,1, 2, nil, 5.d,7.d]
    end
  end

  D "given centre :A, radius :BC, angles [5.d,7.d]" do
    arc(:centre => :A, :radius => :BC, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [3,1, Math.sqrt(2), nil, 5.d,7.d]
    end
  end

  D "given centre :A, diameter :BC, angles [5.d,7.d]" do
    arc(:centre => :A, :diameter => :BC, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [3,1, Math.sqrt(2)/2, nil, 5.d,7.d]
      # Gotta test these methods once!
      Eq a.centroid, nil
      Eq a.points, [p(3,1)]    # An arc's only 'point' is its centre.
    end
  end

  D "given radius :AB, angles [5.d,7.d]" do
    arc(:radius => :AB, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [3,1, 3, nil, 5.d,7.d]
    end
  end

  D "given radius :BA, angles [5.d,7.d]" do
    arc(:radius => :BA, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [6,1, 3, nil, 5.d,7.d]
    end
  end

  D "given diameter :AB, angles [5.d,7.d]" do
    arc(:diameter => :AB, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [4.5,1, 1.5, nil, 5.d,7.d]
    end
  end

  D "given diameter :BA, angles [5.d,7.d]" do
    arc(:diameter => :BA, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [4.5,1, 1.5, nil, 5.d,7.d]
    end
  end

  D "given label, centre p(-7,-2), radius :AC, angles [5.d,7.d]" do
    arc(:M, :centre => p(7,-2), :radius => :AC, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [7,-2, Math.sqrt(17), :M, 5.d,7.d]
    end
  end

  D "given label, centre p(3,-9), diameter :AC, angles [5.d,7.d]" do
    arc(:X, :centre => p(3,-9), :diameter => :AC, :angles => [5.d,7.d]).tap do |a|
      T :arc, a, [3,-9, Math.sqrt(17)/2, :X, 5.d,7.d]
      Eq a.category,     :arc
      Eq a.id,           :arc01
      Eq a.label.symbol, :X
    end
  end

    # This is really a test of Register, but nevermind.
  D "#id, @register.by_id, Circle[n], angles [5.d,7.d]" do
    a1 = arc(:angles => [5.d,7.d])
    a2 = arc(:centre => p(5,6), :radius => 7, :angles => [5.d,7.d])
    Eq a1.id, :arc01
    Eq a2.id, :arc02
    Eq @register.by_id(:arc01), a1
    Eq @register.by_id(:arc02), a2
    Eq Arc[0],  a1
    Eq Arc[1],  a2
    Eq Arc[-1], a2
  end

  SE = RGeom::Err::SpecificationError
  D "invalid specifications --> error" do
    E(SE) { arc(:centre => :F, :angles => [40.d,50.d]) }
    E(SE) { arc(:radius => :DF, :angles => [40.d,50.d]) }
    E(SE) { arc(:radius => :DFG, :angles => [40.d,50.d]) }
    E(SE) { arc(:radius => 4, :diameter => 7, :angles => [40.d,50.d]) }
    E(SE) { arc(:centre => "centre", :angles => [40.d,50.d]) }
    E(SE) { arc(:centre => :AB, :angles => [40.d,50.d]) }
    E(SE) { arc(:centre => p(5,2), :radius => 7) }
  end

end  # TestArc
