  # Create a spiral of triangles, each built on the last.
D "Triangle - construct spiral" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
  end

    # This is a spiral with three right-angled triangles, using named vertices
    # all the way.
  D "three-triangle spiral using named vertices" do
    triangle(:ABC, :right_angle => :A, :base => 3, :height => 1)
    triangle(:CBD, :right_angle => :C, :height => 1)
    triangle(:DBE, :right_angle => :D, :height => 1)
    b = p(:B)
    e = p(:E)
    Ft Point.distance(b,e), Math.sqrt(12)
  end

    # This is a spiral with 10 right-angled triangles, using mostly anonymous vertices.
    # test_spiral_3 is a better way of coding this.
  D "ten-triangle spiral using manual loop" do
    arr = []
    arr << triangle(:ABC, :right_angle => :A, :base => 3, :height => 1)
    9.times do
      p1 = arr.last.apex
      p2 = p(:B)
      arr << triangle(:base => [p1,p2], :right_angle => :first, :height => 1)
    end
    b = p(:B)
    x = arr.last.apex
    Ft Point.distance(b, x), Math.sqrt(19)
  end

    # This does the same as test_spiral_2, but uses Shape.generate and Triangle#hypotenuse.
  D "ten-triangle spiral using Shape.generate and Triangle#hypotenuse" do
    first = triangle(:right_angle => :first, :base => 3, :height => 1)
    Shape.generate(10, first) do |tn|
      triangle(:base => tn.hypotenuse.reverse, :right_angle => :first, :height => 1)
    end
    Ft Triangle[-1].hypotenuse.length, Math.sqrt(19)
    Eq @register.nobjects, 10
      # ^ We're checking that only the 11 triangles end up in the register, not
      #   any extraneous segments (i.e. the hypotenuses).
  end

end  # "Triangle - construct spiral"
