D "Triangle construct - basic" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
  end

  D "default triangle" do
    D "has correct vertices" do
      triangle = _triangle(:ABC)
      Ko triangle, Triangle
        # Could use T :vertices, here, but will leave it for posterity.
      triangle.vertices.tap do |v|
        Eq v[0].x, 0
        Eq v[0].y, 0
        Eq v[1].x, 5
        Eq v[1].y, 0
        Ft v[2].x, 1.93877551
        Ft v[2].y, 2.99937520
      end
    end
    D "goes into register" do
      triangle = triangle(:ABC)
      Eq @register.by_label(:triangle, :ABC), triangle
      Eq @register.by_label(:triangle, :BAC), triangle
      Eq @register.by_label(:triangle, :ACB), triangle
      Eq @register.by_label(:triangle, :CBA), triangle
      Eq Triangle[0], triangle
      Eq triangle.id, :tri01
      Eq triangle.label, :ABC
    end
  end

  D "triangle(:ABC) -- all three points defined" do
    points :A => p(1,1), :B => p(4,0), :C => p(4,4)
    triangle = triangle(:ABC)
    T :vertices, triangle, %w{ A 1 1    B 4 0    C 4 4 }
    Eq @register.by_label(:triangle, :ABC), triangle
# Exact label needed for match at the moment...
#   Eq @register.retrieve(:triangle, :ACB), triangle
    Eq triangle.apex, p(4,4)
  end

  D "default isosceles" do
  end

  D "default equilateral" do
    triangle(:ABC, :equilateral).tap do |t|
      T :vertices, t, %w{A 0 0   B 5 0   C 2.5 4.330127}
    end
  end

  D "scalene with height = 3" do
    t = triangle(:ABC, :scalene, :height => 3)
    T :vertices, t, %w{A 0 0   B 5 0   C 1.5 3}
  end

  D "default right angle triangles (different spec for :right_angle)" do
    t1 = triangle(:ABC, :right_angle => :A)
    T :vertices, t1, %w{A 0 0    B 5 0    C 0 3.75}

    @register.clear!
    t2 = triangle(:ABC, :right_angle => :B)
    T :vertices, t2, %w{A 0 0    B 5 0    C 5 3.75}

    @register.clear!
    t3 = triangle(:ABC, :right_angle => :C)
    T :vertices, t3, %w{A 0 0    B 5 0    C 3.2 2.4}

    # Try it with anonymous vertices.
    @register.clear!
    t4 = triangle(:right_angle => :second)
    T :vertices, t4, %w{_ 0 0    _ 5 0    _ 5 3.75}
  end

end   # "Triangle construct - basic"

