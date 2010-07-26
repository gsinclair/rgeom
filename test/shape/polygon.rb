D "Polygon" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
    debug "Hello"
    sleep 0.2
  end

  D.< do
    debug "Hello"
    sleep 0.2
  end

  D "polygon(:ABCDE)" do
    debug "WTF?"
    polygon(:ABCDE).tap do |s|
      T :vertices, s, %w(A 0 0    B 1 0   C 1.30902  0.95106
                         D 0.5 1.53884    E -0.30902 0.95106)
      T :point, p(0.5,1.53884), s.pt(3)
      T :point, p(0.5,1.53884), @register[:D]
    end
  end

  D "polygon(:n => 6, :base => 2.5)" do
    polygon(:n => 6, :base => 2.5).tap do |s|
      T :vertices, s, %w(_ 0.0 0.0       _ 2.5 0.0       _  3.75 2.16505
                         _ 2.5 4.33013   _ 0.0 4.33013   _ -1.25 2.16506)
    end
  end

## Not sure about this :rotate parameter.  I'd prefer:
##   p = polygon(:n => 3, :start => :A, :base => :3).rotate(-7.d)
##
##   D "polygon(:n => 3, :start => :A, :base => 3, :rotate => -7.d)" do
##     point :X => p(5.977638455,0.6343919698)
##     reference_triangle = _triangle(:equilateral, :base => :AX)
##     polygon(:n => 3, :start => :A, :base => 3, :rotate => -7.d).tap do |s|
##       # Our polygon should be equivalent to an equilateral triangle based on AX.
##       t = reference_triangle
##       Eq s.points, t.points
##       Eq s.base,   _segment(:AX)
##     end
##   end

    # We generate the same shape as above, but use {:base => :AX}
    # instead of {:start => :A, :base => 3, :angle => -7.d}.
  D "polygon(:n => 3, :base => :AX)" do
    point :X => p(5.977638455,0.6343919698)
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
    point :X => p(5,1)
    polygon(:n => 4, :radius => :AX).tap do |s|
      T :vertices, s, %(_ 1.58579 -0.41421   _ 4.41421 -0.41421
                        _ 4.41421  2.41421   _ 1.58579  2.41421)
    end
  end

  D "polygon(:n => 3, :diameter => :AC, :rotate => 35.d)" do
    polygon(:n => 3, :diameter => :AC, :rotate => 35.d).tap do |s|
      T :vertices, s, %w(_ 4.12875 -0.36840   _ 7.05371 1.67968   _ 3.81754 3.18873)
    end
  end

    # Same as test_07, but this time we want some points registered.
  D "polygon(:MNP, :n => 3, :diameter => :AC, :rotate => 35.d)" do
    polygon(:MNP, :n => 3, :diameter => :AC, :rotate => 35.d).tap do |s|
      T :vertices, s, %w(M 4.12875 -0.36840   N 7.05371 1.67968   P 3.81754 3.18873)
    end
  end

  D "polygon(:CWXYZ, :base => 10) with existing C" do
    polygon(:CWXYZ, :base => 10).tap do |s|
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

end  # TestPolygon
