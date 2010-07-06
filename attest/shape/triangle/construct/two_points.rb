  # This class tests the basic triangles (equilateral, simple isosceles, default
  # scalene) in a variety of orientations with (importantly) the two base points
  # defined.
  #
  # For a greater variety of triangles, using the various options like :sides
  # and :angles, see TestTriangleConstructVariousOptions.
D "Triangle construction - two points defined (the base)" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(2,1), :B => p(7,3), :C => p(2,-5), :D => p(-3,-1), :E => p(-1,7)
  end

    # Creates and tests four equilateral triangles.
  D "four equilateral triangles" do
      # First one written out, to demonstrate what it looks like.
    triangle = triangle(:AB_, :equilateral)
    T :vertices, triangle, %w{ A 2 1   B 7 3  _ 2.76795 6.33013 }
      # Rest done in a loop.
    input = [:AC_, :AD_, :AE_]
    output = [
      %w{ A 2 1   C  2 -5     _   7.19615  -2.00000 },
      %w{ A 2 1   D -3 -1     _   1.23205  -4.33013 },
      %w{ A 2 1   E -1  7     _  -4.69615   1.40192 },
    ]
    (0..2).each do |i|
      triangle = triangle(input[i], :equilateral)
      T :vertices, triangle, output[i]
    end
  end

    # Same as test 1, but :BA_ instead of :AB_, which means the triangle will be
    # "upside down" compared to before.
  D "four equilateral triangles (bases reversed)" do
    input = [:BA_, :CA_, :DA_, :EA_]
    output = [
      %w{ B  7  3   A 2 1     _    6.23205  -2.33013 },
      %w{ C  2 -5   A 2 1     _   -3.19615  -2.00000 },
      %w{ D -3 -1   A 2 1     _   -2.23205   4.33013 },
      %w{ E -1  7   A 2 1     _    5.69615   6.59808 },
    ]
    (0..3).each do |i|
      triangle = triangle(input[i], :equilateral)
      T :vertices, triangle, output[i]
    end
  end

  D "four isosceles triangles" do
    input = [:AB_, :AC_, :AD_, :AE_]
    output = [
      %w{ A 2 1   B  7  3     _   2.64305   6.64238 },
      %w{ A 2 1   C  2 -5     _   7.00000  -2.00000 },
      %w{ A 2 1   D -3 -1     _   1.35695  -4.64238 },
      %w{ A 2 1   E -1  7     _  -3.97214   1.76393 },
    ]
    (0..3).each do |i|
      triangle = triangle(input[i], :isosceles, :height => 5)
      T :vertices, triangle, output[i]
    end
  end

  D "four isosceles triangles (bases reversed)" do
    input = [:BA_, :CA_, :DA_, :EA_]
    output = [
      %w{ B  7  3   A 2 1     _    6.35695  -2.64238 },
      %w{ C  2 -5   A 2 1     _   -3.00000  -2.00000 },
      %w{ D -3 -1   A 2 1     _   -2.35695   4.64238 },
      %w{ E -1  7   A 2 1     _    4.97214   6.23607 },
    ]
    (0..3).each do |i|
      triangle = triangle(input[i], :isosceles, :height => 5)
      T :vertices, triangle, output[i]
    end
  end

    # Create and test four scalene (default 5,6,7) triangles.
  D "four scalene triangles" do
    input = [:AB_, :AC_, :AD_, :AE_]
    output = [
      %w{ A 2 1   B  7  3     _   2.73903   4.77489 },
      %w{ A 2 1   C  2 -5     _   5.59925  -1.32653 },
      %w{ A 2 1   D -3 -1     _   1.26097  -2.77489 },
      %w{ A 2 1   E -1  7     _  -2.76252   1.52691 },
    ]
    (0..3).each do |i|
      triangle = triangle(input[i], :scalene)
      T :vertices, triangle, output[i]
    end
  end

    # Reverse of test 3.
  D "four scalene triangles (bases reversed)" do
    input = [:BA_, :CA_, :DA_, :EA_]
    output = [
      %w{ B  7  3   A 2 1     _    6.26097  -0.77489 },
      %w{ C  2 -5   A 2 1     _   -1.59925  -2.67347 },
      %w{ D -3 -1   A 2 1     _   -2.26097   2.77489 },
      %w{ E -1  7   A 2 1     _    3.76252   6.47309 },
    ]
    (0..3).each do |i|
      triangle = triangle(input[i], :scalene)
      T :vertices, triangle, output[i]
    end
  end

    # Use A(1,0) and B(7,0) for some easy testing.
  D "three right-angled triangles (basic)" do
    @register.clear!
    points :A => p(1,0), :B => p(7,0)
    tx = triangle(:ABX, :right_angle => :A, :height => 4)
    ty = triangle(:ABY, :right_angle => :B, :height => 4)
    tz = triangle(:ABZ, :right_angle => :Z, :height => 2)
    T :point, tx.apex, p(1,4)
    T :point, ty.apex, p(7,4)
    T :point, tz.apex, p(1.76393202,2)
  end

  D "four right-angled triangles (complex)" do
    t1 = triangle(:DE_, :right_angle => :D, :height => 9)
    T :point, t1.apex, p(-11.73128,1.18282)

    t2 = triangle(:ED_, :right_angle => :D, :height => 1)
    T :point, t2.apex, p(-2.02986,-1.24254)

    t3 = triangle(:DE_, :right_angle => :apex, :height => 3)
    T :point, t3.apex, p(-5.5964218,0.98362951)
  end

  #def test_5_sas_triangles
  #end

end  # "Triangle construction - two points defined (the base)"
