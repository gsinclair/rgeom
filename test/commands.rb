D "Commands - p, pt, s, seg" do
  D.< {
    @register = RGeom::Register.instance
    @register.clear!
    points :G => [-3,0.5], :H => [0,1]
  }

  D "Points" do
    D "p(5,5)" do
      Ko pt(5,5),   Point
      Ko p(5,5),    Point
      Eq pt(9,4).x, 9
      Eq pt(9,4).y, 4
    end

    D "p(:G)" do
      Ko pt(:G), Point
      Ko p(:G),  Point
      Eq pt(:G).x, -3
      Eq p(:G).y,  0.5
    end

    D "p(point)" do
      p1 = Point[5,2]
      Ko pt(p1), Point
      Ko p(p1),  Point
      Eq pt(p1).x, 5
      Eq p(p1).y,  2
    end

    D "p(nil)" do
      N p(nil)
      N pt(nil)
    end
  end  # Points

  D "Segments" do
    D "s(:GH) and seg(:GH) create a segment" do
      Ko seg(:GH), Segment
      Ko   s(:GH), Segment
    end
    D "p and q return the start and end points of the segment" do
      Eq seg(:GH).p, p(:G)
      Eq   s(:GH).q, p(:H)
    end
    D "s() and seg() can take points as arguments" do
      Ko seg( p(4,2), p(7,1) ),    Segment
      Ko   s( p(4,2), p(7,1) ),    Segment
      Eq seg( p(4,2), p(7,1) ).p,  p(4,2)
      Eq   s( p(4,2), p(7,1) ).q,  p(7,1)
    end
    D "s(nil)" do
      N seg(nil)
      N   s(nil)
    end
    D "s() and seg() can take a segment as an argument" do
      Ko s( seg(:GH) ),    Segment
      Ko seg( s(:GH) ),    Segment
      Ko seg( seg(:GH) ),  Segment
      Ko s( s(:GH) ),      Segment
      Eq s( s(:GH) ).p,                p(:G)
      Eq s( s( s(:GH))).p,             p(:G)
      Eq s( s( s( s( s( s(:GH)))))).q, p(:H)
    end
  end  # Segments
end
