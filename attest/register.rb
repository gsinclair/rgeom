D "Register" do
  D.< do
    @register = RGeom::Register.instance
    @register.clear!
  end

  D "points :A => p(3,9) updates register" do
    points :A => p(3,9), :B => p(0,-2.543)
    Eq @register[:A], p(3,9)
    Eq @register[:B], p(0,-2.543)
    Eq @register.npoints, 2
    Eq @register.nobjects, 0
  end

  D "@register[:S] = p(4,3) updates register" do
    @register[:S] = p(4,3)
    Eq @register[:S], p(4,3)
    Eq @register.npoints, 1
    Eq @register.nobjects, 0
    D "and p(:S) == p(4,3)" do
      Eq p(:S), p(4,3)
    end
  end

  D "triangle(:GMK)" do
    D "@register.by_label(:triangle, :GMK)" do
      points :G => p(0,0), :M => p(1,0), :K => p(0.39,0.60)
      t = triangle(:GMK)
      Eq @register.by_label(:triangle, :GMK), t
      Eq @register.by_label(:triangle, :GKM), t
      Eq @register.by_label(:triangle, :KMG), t
      Eq @register.by_label(:triangle, :KGM), t
      Eq @register.by_label(:triangle, :MGK), t
      Eq @register.by_label(:triangle, :MKG), t
      Eq @register.by_label(:triangle, :ABC), nil
      Eq @register.nobjects, 1
    end
  end

  D "point reassignment raises error" do
    points :A => p(3,9), :B => p(0,-2.543)
    E(ArgumentError) { @register[:A] = p(4,-1) }
    E(ArgumentError) { points    :A => p(4,-1) }
  end

end
