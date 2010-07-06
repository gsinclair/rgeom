D "Square" do

  D.< do
    @register = RGeom::Register.instance
    @register.clear!
    points :A => p(3,1), :B => p(7,-2)
  end

  D "default (with labels)" do
    square(:MNOP).tap do |s|
      T :square, s, %w(0 0   5 0   5 5   0 5)
      Eq @register[:M], p(0,0)
      Eq @register[:N], p(5,0)
      Eq @register[:O], p(5,5)
      Eq @register[:P], p(0,5)
      Eq s.side, 5
    end
  end

  D "default (sans labels)" do
    square().tap do |s|
      T :square, s, %w(0 0   5 0   5 5   0 5)
    end
  end

  D "given one vertex" do
    square(:A___).tap do |s|
      T :square, s, %w(3 1   8 1   8 6   3 6)
      Eq @register[:A], p(3,1)
      Eq s.side, 5
    end
  end

  D "given one vertex and side length" do
    square(:A___, :side => 1.5).tap do |s|
      T :square, s, %w(3 1   4.5 1   4.5 2.5   3 2.5)
      Eq s.side, 1.5
    end
  end

  D "given two vertices" do
    square(:AB__).tap do |s|
      T :square, s, %w(3 1   7 -2   10 2   6 5)
      Eq s.side, 5
    end
  end

  D "given base segment I" do
    square(:base => :AB).tap do |s|
      T :square, s, %w(3 1   7 -2   10 2   6 5)
      Eq s.side, 5
    end
  end

  D "given base segment II" do
    square(:base => _segment(:AB)).tap do |s|
      T :square, s, %w(3 1   7 -2   10 2   6 5)
      Eq s.side, 5
    end
  end

  D "given two vertices (and labels for the other two)" do
    square(:BARF).tap do |s|
      T :square, s, %w(7 -2   3 1   0 -3   4 -6)
      Eq s.side, 5
      Eq @register[:R], p(0,-3)
      Eq @register[:F], p(4,-6)
    end
  end

  D "given base segment III" do
    square(:base => :BA).tap do |s|
      T :square, s, %w(7 -2   3 1   0 -3   4 -6)
      Eq s.side, 5
    end
  end

  D "given base segment IV" do
    square(:base => _segment(:BA)).tap do |s|
      T :square, s, %w(7 -2   3 1   0 -3   4 -6)
      Eq s.side, 5
    end
  end

  D "given diagonal I" do
    diagonal = Segment.simple( Point[-6,-2], Point[3,3] )
    square(:diagonal => diagonal).tap do |s|
      T :square, s, %w(-6 -2   1 -4   3 3   -4 5)
      Ft s.side, 7.28011
    end
  end

  D "given diagonal II" do
    diagonal = Segment.simple( Point[3,3], Point[-6,-2] )
    square(:diagonal => diagonal).tap do |s|
      T :square, s, %w(3 3   -4 5   -6 -2   1 -4)
      Ft s.side, 7.28011
    end
  end

end  # "Square"
