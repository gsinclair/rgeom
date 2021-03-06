  # This class tests proper arc features.  See TestArcBasic for simple tests
  # (based on Circle).
D "Arc (complex)" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(6,1), :C => p(7,2)
  end

  D ":radius => :AB, :angles => [0.d,180.d]" do
    arc(:radius => :AB, :angles => [0.d,180.d]).tap do |a|
      T :arc, a, [3,1, 3, nil, 0.d,180.d]
      Eq a.start,            p(6,1)
      Eq a.end,              p(0,1)
      Eq a.interpolate(0.5), p(3,4)
      Eq a.interpolate(0.6), p(2.072949017, 3.853169549)
      # ---
      Eq a.angles,           [0.d,180.d]
      Eq a.relative_angles,  [0.d,180.d]
      Eq a.absolute_angles,  [0.d,180.d]
      Eq a.angle_offset,     0.d
      Eq a.centre_angle,     180.d
      Eq a.bounding_box,     [p(0,1),p(6,4)]
    end
  end

    # Exactly the same as test_01, but using 'semicircle' to create the shape.
  D "semicircle :radius => :AB" do
    semicircle(:radius => :AB).tap do |a|
      T :arc, a, [3,1, 3, nil, 0.d,180.d]
      Eq a.start,            p(6,1)
      Eq a.end,              p(0,1)
      Eq a.interpolate(0.5), p(3,4)
      Eq a.interpolate(0.6), p(2.072949017, 3.853169549)
      # ---
      Eq a.angles,           [0.d,180.d]
      Eq a.relative_angles,  [0.d,180.d]
      Eq a.absolute_angles,  [0.d,180.d]
      Eq a.angle_offset,     0.d
      Eq a.centre_angle,     180.d
      Eq a.bounding_box,     [p(0,1),p(6,4)]
    end
  end

  D "unusual angles [310.d,195.d]" do
    arc(:angles => [310.d,195.d]).tap do |a|
      Eq a.angles,             [-50.d,195.d]
      Eq a.centre_angle,       245.d
      Eq a.contains?(0.d),     true
      Eq a.contains?(90.d),    true
      Eq a.contains?(180.d),   true
      Eq a.contains?(270.d),   false
      Eq a.bounding_box,       [p(-1,-0.766044431),p(1,1)]
      Eq a.relative_angles,    [-50.d,195.d]
      Eq a.absolute_angles,    [-50.d,195.d]
      Eq a.interpolate(0.217), p(0.9984746773,0.05521158186)
      Eq a.start,              p(0.6427876097,-0.766044431)
      Eq a.end,                p(-0.9659258263,-0.2588190451)
    end
  end

  D "semicircle :diameter => :AC" do
    semicircle(:diameter => :AC).tap do |a|
      Eq a.angles,          [0.d,180.d]
      Eq a.relative_angles, [0.d,180.d]
      Eq a.angle_offset,    14.03624347.d
      offset = a.angle_offset
      Eq a.absolute_angles, [0.d+offset,180.d+offset]
      Eq a.start,           p(7,2)
      Eq a.end,             p(3,1)
    end
  end

end  # class TestArcComplex

