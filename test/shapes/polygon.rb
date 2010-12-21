D "Polygon" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
  end

  D "polygon(:LMNOP) -- basic pentagon" do
    poly = polygon(:LMNOP)
    poly.tap do |s|
      T :vertices, s, %w(L 0 0    M 1 0   N 1.30902  0.95106
                         O 0.5 1.53884    P -0.30902 0.95106)
      T :point, p(0.5,1.53884), s.pt(3)
      T :point, p(0.5,1.53884), @register[:O]
    end
  end

  D "polygon(:ABXYZ) -- A and B defined" do
    polygon(:ABXYZ).tap do |s|
      T :vertices, s, %w(A 0 0    B 1 0   X 1.30902  0.95106
                         Y 0.5 1.53884    Z -0.30902 0.95106)
      T :point, p(0.5,1.53884), s.pt(3)
      T :point, p(0.5,1.53884), @register[:Y]
    end
  end

  D "polygon(:n => 6, :side => 2.5)" do
    polygon(:n => 6, :side => 2.5).tap do |s|
      T :vertices, s, %w(_ 0.0 0.0       _ 2.5 0.0       _  3.75 2.16505
                         _ 2.5 4.33013   _ 0.0 4.33013   _ -1.25 2.16506)
    end
  end

  D "polygon(:n => 3, :base => :AX)" do
    points :X => p(5.977638455,0.6343919698)
    reference_triangle = _triangle(:equilateral, :base => :AX)
    polygon(:n => 3, :base => :AX).tap do |s|
      t = reference_triangle
      Eq s.points, t.points
      Eq s.base,   _segment(:AX)
    end
  end

  D "polygon(:n => 4, :centre => :A, :radius => 2)" do
    polygon(:n => 4, :centre => :A, :radius => 2).tap do |s|
      T :vertices, s, %(_ 1.58579 -0.41421   _ 4.41421 -0.41421
                        _ 4.41421  2.41421   _ 1.58579  2.41421)
    end
  end

    # Same polygon as last test, but constructed differently.
  D "polygon(:n => 4, :radius => :AX)" do
    points :X => p(5,1)
    polygon(:n => 4, :radius => :AX).tap do |s|
      T :vertices, s, %(_ 1.58579 -0.41421   _ 4.41421 -0.41421
                        _ 4.41421  2.41421   _ 1.58579  2.41421)
    end
  end

  D "polygon(:n => 3, :diameter => :AC)" do
    polygon(:n => 3, :diameter => :AC).tap do |s|
      # These points will be wrong because I removed the _rotate_ parameter.
      xT :vertices, s, %w(_ 4.12875 -0.36840   _ 7.05371 1.67968   _ 3.81754 3.18873)
    end
  end

    # Same as last test, but this time we want some points registered.
  D "polygon(:MNP, :n => 3, :diameter => :AC)" do
    polygon(:MNP, :n => 3, :diameter => :AC).tap do |s|
      # These points will be wrong because I removed the _rotate_ parameter.
      xT :vertices, s, %w(M 4.12875 -0.36840   N 7.05371 1.67968   P 3.81754 3.18873)
    end
  end

  D "polygon(:CWXYZ, :side => 10) with existing C" do
    polygon(:CWXYZ, :side => 10).tap do |s|
      T :vertices, s,
        %w(C 7.0 2.0     W 17.0 2.0     X 20.09017 11.51057
                                        Y 12.0     17.38842     Z 3.90983 11.51057)
    end
  end

  D "polygon(:CBHI) with existing C and B" do
    polygon(:CBHI).tap do |s|
      T :vertices, s, %w(C 7 2   B 6 1   H 7 0   I 8 1)
    end
  end

end  # D "Polygon"
