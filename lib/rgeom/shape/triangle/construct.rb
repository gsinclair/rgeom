
module RGeom; class Triangle; class Constructor

  DEFAULT_BASE = 5

  def initialize(data)
    @data = data
    @p, @q, @r = data.vertex_list.points
    if data.vertex_list.mask =~ /TT./
      # We can calculate the base length, which may be necessary for construction
      # of unit triangle.  We might as well calculate the angle as well.
      r, t = Point.relative(@p, @q).polar
      @base_length = r
      @base_angle  = t
    end
  end

    # First see if all three points are defined.  If so, no construction is
    # necessary.  Otherwise...
    #
    # Create a unit triangle based on the size information given, then
    # transform it to be in the correct place.
  def construct
    if @data.vertex_list.mask == "TTT"
      # Nothing to construct.
    else
      unit_triangle =
        case @data.type
        when :equilateral
          unit_equilateral
        when :isosceles
          unit_isosceles
        when :scalene
          unit_scalene
        when :right_angle
          unit_right
        when nil
          unit_scalene  # For now...
        end
      points = transform(unit_triangle)
      @data.vertex_list.accommodate(points)
    end
    Triangle.new(@data.vertex_list, @data.type)
      # ^^^ data.vertex_list gets updated by the construction methods
  end

    # input  : PointList (unit triangle)
    # output : PointList (scaled triangle)
  def transform(unit_triangle)
    # The unit triangle has a base of 1.  We need to determine the length of the
    # desired base, either by calculating a distance (say :AB) or using the
    # :base specification.  We then scale by that factor.
    #
    # The unit_triangle has a _flat_ base between (0,0) and (1,0).  We need to
    # determine the _angle_ of the base (probably by calculating the angle :AB).
    # We then rotate by that amount.
    #
    # The unit triangle has its starting point at the origin.  We need to
    # determine the desired starting point (:A) and translate the triangle.
    #
    # The actual transformation is handled by the PointList class.  This method
    # determines the appropriate amounts of scaling, reflection and rotation.
    # It looks at the length and angle of the desired base.
    
    scale, angle, vector = 1, 0, [0,0]    # Default values: identity transform
      # In the following comments, it's assumed the vertices are named A, B and C.
    case @data.vertex_list.mask
    when /F../
      # A is undefined, so we ignore others and default everything.
      scale = @data.base || DEFAULT_BASE
      angle = 0
      vector = Point[0,0]
    when /TF./
      # A is defined but B is not.
      scale = @data.base || DEFAULT_BASE
      angle = 0
      vector = @p
    when /TTF/
      # A and B are defined, so we use the base length and angle that were calculated
      # in #initialize.
      scale = @base_length
      angle = @base_angle
      vector = @p
    when /TTT/
      # Shouldn't get here; if all points are defined, there's no need to
      # construct or transform anything.
    end
    unit_triangle.transform(scale, angle, vector)
  end

  def unit_equilateral
    PointList[[0,0], [1,0], [0.5,0.8660254038]]
  end

  def unit_isosceles
    base, height, angle, side =
      @data.values_at(:base, :height, :angle, :side)
    base = @base_length || base
      # ^ The calculated base length takes precedence over a specified one.
    unit_height =
      if height
        height.to_f / base
      elsif angle
        Math.tan(angle) / 2
      elsif side
        unit_side = side/base
        Math.sqrt(unit_side * unit_side - 0.25)
      end
    apex = [0.5, unit_height]
    PointList[[0,0], [1,0], apex]
  end

  def unit_scalene
    base, height, angles, sides =
      @data.values_at(:base, :height, :angles, :sides)
    base = @base_length || base || DEFAULT_BASE
      # ^ The calculated base length takes precedence over a specified one.
    apex =
      if angles
        # Using a base of 1, it's easy to calculate the apex.
        alpha, beta = d2r(angles[0], angles[1])
        x = Math.tan(beta) / (Math.tan(alpha) + Math.tan(beta))
        y = x * Math.tan(alpha)
        [x,y]
      elsif sides
        unless sides.size == 3
          raise ArgumentError,
            "Must have three sides for scalene triangle #{@data.vertex_names}"
        end
        # We calculate left base angle (alpha) in order to locate apex.
        base = sides.first   # This seems dodgy...
        c, a, b = sides.map { |d| d.to_f / base }  # Scale down to unit base.
        cos_alpha = (b*b + c*c - a*a) / (2*b*c)
        sin_alpha = Math.sqrt(1 - cos_alpha**2)
        x = b * cos_alpha
        y = b * sin_alpha
        [x,y]
      elsif height
        unit_height = height.to_f / base
        x = 0.3
        y = unit_height
        [x,y]
      else
        [0.387755102, 0.5998750391]  # default scalene: 5,6,7 triangle
      end
    PointList[[0,0], [1,0], apex]
  end

    # A triangle that is specified to be right-angled must tell us which angle
    # is the right angle.  The only other piece of information we can use is
    # the height (default to 0.7 * base for a pleasing aesthetic).
    # 
    # The following code _implicitly_ creates a right-angled triangle and is
    # handled by unit_scalene.
    #   triangle(:ABX, :angles => [90.d, 30.d])
    #
    # Defaults to a 3-4-5 triangle (what else?), such that (psuedo-code)
    #   triangle(:right_angle => :A) == triangle(:sides => [4,5,3])
  def unit_right
    vertex_list, right_angle, base, height =
      @data.values_at(:vertex_list, :right_angle, :base, :height)
    base = @base_length || base
      # ^ The calculated base length takes precedence over a specified one.
    v1, v2, v3 = vertex_list.vertex_names
    right_angle ||= v1
    # TODO: Try to simplify/refactor this code.  Unify the default and generated
    # right-angled triangles.
    if base.nil? and height.nil?
      apex =
        case right_angle
        when v1, 1, :first then @data.base = 4; [0, 0.75]
        when v2, 2, :second then @data.base = 4; [1, 0.75]
        when v3, 3, :apex, :third then @data.base = 5; [0.64, 0.48]
        else Err.right_angle_not_in_triangle(right_angle, vertex_list.vertex_names)
        end
      return PointList[[0,0], [1,0], apex]
    end
    (base = height / 0.7; @data.base = base) if base.nil?
    (height = base * 0.7; @data.height = height) if height.nil?
    unit_height = height.to_f / base
    # From this point on, 'base' and 'height' are defined.
    apex =
      case right_angle        # which vertex contains the right-angle?
      when v1, 1, :first
        [0, unit_height]
      when v2, 2, :second
        [1, unit_height]
      when v3, :apex, 3, :third
        # Right-angle is at the apex, which is more complicated.
        # There are two solutions, which we'll allow with :slant => {:left,:right}
        if unit_height > 0.5
          Err.invalid_height_in_right_angled_triangle([v1,v2,v3], base, height)
        end
        a = Math.sqrt(1 - 4 * unit_height**2)
        x_ = { :left => (1 - a)/2, :right => (1 + a)/2 }
        slant = @data.unprocessed[:slant]
        if slant != :left and slant != :right
          slant = :left
        end
        x = x_[slant]
        y = unit_height
        [x,y]
      else Err.right_angle_not_in_triangle(right_angle, vertex_names)
      end
    PointList[[0,0], [1,0], apex]
  end

  def hypotenuse(a, b)
    Math.sqrt(a*a + b*b)
  end

  def d2r(*vals)
    vals.map { |a| a * Math::PI / 180 }
  end
end; end; end  # class RGeom::Triangle::Constructor

