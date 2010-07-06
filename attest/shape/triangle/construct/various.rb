  # Tests triangles with various specifications (e.g. sides/angles/height).
  # The focus is simply on finding the correct apex; other test cases have
  # covered the basics of the Triangle and Register class adequately.
D "Triangle construct - various" do
  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :M => p(-3,-7), :K => p(4,0), :C => p(5,-2)
  end

  D "triangle(:MAT, :base => 10, :angles => [15.d, 10.d])" do
    triangle = triangle(:MAT, :base => 10, :angles => [15.d, 10.d])
    T :point, triangle.apex, p(0.96886, -5.93655)
  end

  D "triangle(:CK_, :angles => [33.d, 40.d])" do
    triangle = triangle(:CK_, :angles => [33.d, 40.d])
    T :point, triangle.apex, p(3.7041144689,-1.2386455559)
  end

  D "triangle(:PQR, :sides => [5,8,7])" do
    triangle = triangle(:PQR, :sides => [5,8,7])
    T :point, triangle.apex, p(1.000000, 6.92820)
    T :point, @register[:P], p(0,0)
    T :point, @register[:Q], p(5,0)
    T :point, @register[:R], p(1.000000, 6.92820)
  end

  D "triangle(:PQR, :scalene, :base => 11, :height => 8)" do
    triangle = triangle(:PQR, :scalene, :base => 11, :height => 8)
    T :point, @register[:P], p(0,0)
    T :point, @register[:Q], p(11,0)
    T :point, @register[:R], p(3.3,8)
  end

  D "triangle(:MK_, :scalene, :height => 4)" do
    triangle = triangle(:MK_, :scalene, :height => 4)
    T :point, triangle.apex, p(-3.728427,-2.071573)
  end

  D "triangle(:ABX, :right_angle => :A, :height => 3) and other RATs" do
    @register.clear!
    points :A => p(0,1), :B => p(7,0)
    tx = triangle(:ABX, :right_angle => :A, :height => 3)
    ty = triangle(:ABY, :right_angle => :B, :height => 3)
    tz = triangle(:ABZ, :right_angle => :Z, :height => 3)
    T :point, tx.apex, p(0.424264,3.969848)
    T :point, ty.apex, p(7.424264,2.969848)
    T :point, tz.apex, p(2.072238,3.734424)
  end

  D "triangle(:equilateral, :base => :KC)" do
    t = triangle(:equilateral, :base => :KC)
    T :point, t.apex, p(6.23205,-0.13397)
  end

  D "triangle(:equilateral, :base => [k,c])" do
    k = @register[:K]
    c = @register[:C]
    t = triangle(:equilateral, :base => [k,c])
    T :point, t.apex, p(6.23205,-0.13397)
  end

end  # "Triangle construct - various"
