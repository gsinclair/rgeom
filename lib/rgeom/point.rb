
module RGeom

  class Point
    fattrs :x, :y
    include Math
    PRECISION_DEFAULT = 3    # for printing

      # Defines a point by _cartesian_ coordinates.  See Point.polar.
    def initialize(x,y)
      @x, @y = Float(x), Float(y)
      _normalise_zero
    end

      # Returns a point representing the coordinates of b relative to a.
      # Both arguments must be Point objects.
    def Point.relative(a, b)
      Point[b.x - a.x, b.y - a.y]
    end

    def Point.polar(r, t)
      Point[r * cos(t), r * sin(t)]
    end

    def Point.distance(a, b)
      relative(a, b).polar[0]
    end

      # Angle from first point to second.  Result ranges from -PI to PI.
    def Point.angle(a, b)
      relative(a, b).polar[1]
    end

      # TODO: I don't think this belongs in Point.  Util?  Calc?  Geometry?
    def Point.midpoint(a, b)
      x = (a.x + b.x) / 2
      y = (a.y + b.y) / 2
      Point[x,y]
    end

    def ==(other)
      raise NotImplementedError
    end

    def to_a
      [@x, @y]
    end

    def to_s(precision=nil)
      precision ||= @@precision
      sprintf "(%.*f,%.*f)", precision, @x, precision, @y
    end
    def inspect; "Point: #{self.to_s}"; end

    def ==(other)
      if other.nil?
        false
      else
        Float.close?(@x, other.x) and Float.close?(@y, other.y)
      end
    end

      # Scale by a factor of _k_.  Centre of enlargement is the origin.
    def scale(k)
      Point.new(k*@x, k*@y)
    end

      # Rotate by th radians anticlockwise about the origin.
    def rotate(th)
      x = @x*cos(th) - @y*sin(th)
      y = @x*sin(th) + @y*cos(th)
      Point.new(x,y)
    end

      # vector: [5,2] or Point[5,2]
    def translate(vector)
      v = Point[vector]
      Point.new(@x + v.x, @y + v.y)
    end

      # Returns the polar values _r_ and _t_ for this point.
    def polar
      r = sqrt(@x*@x + @y*@y)
      t = atan2(@y, @x)
      [r, t]
    end

      # Like this:
      #   p1 = Point[3,2]
      #   p2 = Point[p1]
      #   coords = [3,2]
      #   p3 = Point[coords]
      #   
      #   p1 == p2 == p3
      #
      #   Point[nil]   # --> nil
    def Point.[](*args)
      args = args.flatten
      case args.first
      when Point
        return args.first
      when nil
        return nil
      else
        return Point.new(*args)
      end
    end

    def Point.precision=(n)
      @@precision = n || PRECISION_DEFAULT
    end
    Point.precision = nil

    private
    def _normalise_zero
      @x = 0.0 if @x == -0.0
      @y = 0.0 if @y == -0.0
    end

  end  # class Point







  class PointList
      # +points+:: array of Points
    def initialize(points)
      @points = points
    end

      # PointList[p(7,1), p(3,-5), p(0.2,1.7)]  or
      # PointList[[7,1], [3,-5], [0.2,1.7]]
    def PointList.[](*args)
      PointList.new args.map { |arg| Point[arg] }
    end

      # Scale, rotate and translate the points in this list.  Returns new list.
    def transform(scale, angle, vector)
      @points.map { |p|
        p.scale(scale).
          rotate(angle).
          translate(vector)
      }
    end

      # In-place version of #transform.
    def transform!(scale, angle, vector)
      @points = transform(scale, angle, vector)
    end

      # Returns bottom-left and top-right points for rectangle that completely
      # encloses this collection of points.
      # 
      # Sample return value:
      #   [p(2,1), p(5, 8)]
    def bounding_box
      x_values = @points.map { |p| p.x }
      y_values = @points.map { |p| p.y }
      bottom_left = Point[x_values.min, y_values.min]
      top_right   = Point[x_values.max, y_values.max]
      [bottom_left, top_right]
    end

    def centroid
      xs = @points.map { |p| p.x }
      ys = @points.map { |p| p.y }
      x = (xs.inject(0) { |acc,n| acc + n }).to_f / xs.size
      y = (ys.inject(0) { |acc,n| acc + n }).to_f / ys.size
      Point[x, y]
    end

    def to_s
      "PointList: ".green.bold + @points.map { |p| p.to_s }.join(' ')
    end
    def inspect; to_s; end

    def ==(other)
      self.points == other.points
    end

    def points; @points; end
    protected :points

  end  # class PointList

end  # module RGeom


