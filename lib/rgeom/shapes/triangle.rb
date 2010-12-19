
module RGeom::Shapes

  # *------------------* General triangle code *------------------* 

  class Triangle < RGeom::Shape

    def self.construct(spec)
      Triangle::Constructor.new(spec).result
    end

    CATEGORY = :triangle

      # _vertices_ is a VertexList
      #       [ Vertex[:A, 0,0], Vertex[:B, 1,0], Vertex[:C, 0.39,0.60] ]
    attr_reader :vertices   

    def initialize(vertex_list, type)
      super(vertex_list)
      @type = type
      @points = @vertices.points
    end

    def to_s(mode=:long)
      label = @label || "(no label)"
      if mode == :short
        "Triangle #{label} " + @points.map { |p| p.to_s(1) }.join(" ")
      elsif mode == :long
        "Triangle #{label}:\n  ".green.bold + @vertices.to_s(:long)
      else
        Err.invalid_display_mode(mode)
      end
    end
    def inspect; to_s(:short); end
    def label; @label; end

    def apex
      @points.last
    end

    def base
      Segment.simple(@points[0], @points[1])
      # ^^^ Original code was other way round.  Reason?
    end

    def hypotenuse
      if @type == :right_angle
        Segment.simple( @points[1], @points[2] )
      end
    end

  end  # class Triangle
end  # module RGeom::Shapes


# *---------------------* Triangle construction code *---------------------*


class RGeom::Shapes::Triangle
  # Usage:
  #   Triangle::Constructor.new(spec).result     # -> Triangle
  class Constructor
    DEFAULT_BASE = 5

    def initialize(spec)
      @spec = spec
      @vertices = VertexList.resolve(3, spec.label)
      @p, @q, @r = @vertices.points
      @p, @base_length, @base_angle = determine_base_information
        # At this point, we know we don't have a clash between the label and the
        # 'base' parameter, so we can proceed with confidence.  We shouldn't have
        # to look at the 'base' parameter again.  @p may be affected if given
        # <tt>triangle :equilateral, :base => AB</tt>, for instance.  The first
        # point then is A and the second is B (but we only need to set the first
        # one for construction purposes.
    end

    def result
      if @vertices.mask == "TTT"
        # Nothing to construct.
      else
        unit_triangle =
          case @spec.type
          when :equilateral
            unit_equilateral
          when :isosceles
            unit_isosceles
          when :scalene
            unit_scalene
          when nil      # Should this be :_  ???
            if @spec.right_angle
              @spec.type = :right_angle
              unit_right
            else
              unit_scalene
            end
          end
        points = transform(unit_triangle)
        @vertices.accommodate(points)
      end
      Triangle.new(@vertices, @spec.type)
    end

      # Returns starting point, base length and base angle.
      # The following table shows the results returned when various pieces of
      # information are given.  The 'starting point' is generally set to the
      # existing value of it (@p), signified here by '-'.  Only in one of the
      # situations does it need to be set: when <tt>:base => :CD</tt>.
      #
      #   Triangle spec (excerpt)            Result
      #   -------------                      ------
      #   triangle :CDM                      [-, 4.1332, 31]
      #   triangle :base => :CD              [C, 4.1332, 31]
      #   triangle :base => 5                [-, 5, 0]
      #   triangle                           [-, nil, 0]
      #   triangle :CDM, :base => 13         error,     if C and D exist
      #   triangle :CDM, :base => 13         [-, 13, 0]    if D doesn't exist
      #   triangle :ABC, :base => :XY        error
      #
      # Note that when no base information is available, the return value is
      # <tt>[nil, 0]</tt> so that other code is aware of the lack of information.
      #
    def determine_base_information
      # 1. Check for a couple of error conditions.
      if @spec.label and @spec.base.is_a? Segment
        error "Inappropriate combination of label and base"
      end

      # 2. See if the label has enough information for us about the base.
      if @vertices.mask =~ /TT./
        # The first two points specified in the label exist, so we know something
        # about the base of the triangle.
        if @spec.base
          error "Can't specify existing points _and_ a base"
        end
        r, th = Point.relative(@p, @q).polar
        return [@p, r, th]
      end

      # 3. See if the 'base' parameter was specified.
      case @spec.base
      when Segment
        [@spec.base.p, @spec.base.length, @spec.base.angle]
      when Numeric
        [@p, @spec.base, 0.d]
      when nil
        [@p, nil, 0.d]
      else
        error "Invalid type/value for 'base': #{@spec.base.inspect}"
      end
    end

    def unit_equilateral
      PointList[[0,0], [1,0], [0.5,0.8660254038]]
    end

    def unit_isosceles
      base = @base_length
      height, angle, side = @spec.indices(:height, :angle, :side)
      unit_height =
        if height
          height.to_f / base
        elsif angle
          Math.tan(angle.rad) / 2
        elsif side
          unit_side = side/base
          Math.sqrt(unit_side * unit_side - 0.25)
        end
      apex = [0.5, unit_height]
      PointList[[0,0], [1,0], apex]
    end

    def unit_scalene
      height, angles, sides =
        @spec.indices(:height, :angles, :sides)
      # For a unit scalene, we have points at (0,0) and (1,0); we just
      # need to determine the apex.
      apex =
        if angles
          # Given the base angles, we use trigonometry to calculate the apex.
          alpha, beta = angles[0].rad, angles[1].rad
          x = Math.tan(beta) / (Math.tan(alpha) + Math.tan(beta))
          y = x * Math.tan(alpha)
          [x,y]
        elsif sides
          # Given three side lengths, we treat the first one as the base (using
          # our usual system of anti-clockwise ordering), ...
          base = sides.first
          # ...then scale all side-lengths down to a unit base, ...
          c, a, b = sides.map { |d| d.to_f / base }
          # ...use the cosine rule to determine the left angle, ...
          cos_alpha = (b*b + c*c - a*a) / (2*b*c)
          # ...find the sine of the left angle, ...
          sin_alpha = Math.sqrt(1 - cos_alpha**2)
          # ...and convert polar coordinates into cartesian coordinates.
          x = b * cos_alpha
          y = b * sin_alpha
          [x,y]
        elsif height
          # Given the height of the triangle, and that it's meant to be scalene,
          # we choose an off-centre apex.
          base = @base_length || DEFAULT_BASE
          unit_height = height.to_f / base
          x = 0.3
          y = unit_height
          [x,y]
        else
          # If nothing is specified, we use a 5-6-7 triangle as our default.
          [0.387755102, 0.5998750391]
        end
      PointList[[0,0], [1,0], apex]
    end

    def unit_right
      right_angle = @spec.right_angle || :first
      base        = @base_length
      height      = @spec.height
      v1, v2, v3 = @vertices.vertex_names
      if base.nil? and height.nil?
        # We have no base or height information and so we use a 3-4-5 triangle as our
        # default, scaled down to unit base.
        apex =
          case right_angle
          when v1, :first, :left    then [0, 0.75]
          when v2, :second, :right  then [1, 0.75]
          when v3, :third, :apex    then [0.64, 0.48]
          else                      error "Invalid argument for 'right_angle'"
          end
        return PointList[[0,0], [1,0], apex]
      end
      # Default right-angled triangles; trying to avoid using this code.
      # Only if the defaults are ugly will I revisit it.
      ### if base.nil? and height.nil?
      ###   apex =
      ###     case right_angle
      ###     when v1, 1, :first then @data.base = 4; [0, 0.75]
      ###     when v2, 2, :second then @data.base = 4; [1, 0.75]
      ###     when v3, 3, :apex, :third then @data.base = 5; [0.64, 0.48]
      ###     else Err.right_angle_not_in_triangle(right_angle, vertex_list.vertex_names)
      ###     end
      ###   return PointList[[0,0], [1,0], apex]
      ### end
      base ||= DEFAULT_BASE
      height ||= (base * 0.7)
      unit_height = height.to_f / base
      apex =
        case right_angle        # which vertex contains the right-angle?
        when v1, :first, :left
          [0, unit_height]
        when v2, :second, :right
          [1, unit_height]
        when v3, :third, :apex
          # Right-angle is at the apex, which is more complicated.
          # There are two solutions, which we'll allow with :slant => {:left,:right}
          if unit_height > 0.5
            error "Impossible triangle; height can't exceed #{0.5 * base}"
          end
          a = Math.sqrt(1 - 4 * unit_height**2)
          x =
            if @spec.slant == :right
              (1 + a)/2
            else
              (1 - a)/2
            end
          y = unit_height
          [x,y]
        else
          error "Invalid argument for 'right_angle'"
        end
      PointList[[0,0], [1,0], apex]
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

      scale, angle, vector = 1, 0.d, [0,0]    # Default values: identity transform
        # In the following comments, it's assumed the vertices are named A, B and C.
      case @vertices.mask
      when /F../
        # A is undefined, so we ignore others and default everything.
        scale = @base_length  || DEFAULT_BASE
        angle = @base_angle   || 0.d
        vector = @p           || Point[0,0]
      when /TF./
        # A is defined but B is not.
        scale = @base_length || DEFAULT_BASE
        angle = 0.d
        vector = @p
      when /TTF/
        # A and B are defined, so we use the base length and angle that were calculated
        # in #initialize.
        scale = @base_length
        angle = @base_angle
        vector = @p
      when /F.*T/
        # If non-existing points are specified in the label before existing points,
        # we have a problem.
        error "Invalid label: non-existing point(s) precede existing one(s)"
      when /TTT/
        # Shouldn't get here; if all points are defined, there's no need to
        # construct or transform anything.
      end
      debug [scale, angle, vector].inspect if $test_unit_current_test =~ /two_points/
      unit_triangle.transform(scale, angle, vector)
    end

    def error(message)
      Err.invalid_spec(:triangle, @spec, message)
    end

  end  # class Constructor
end  # class RGeom::Shapes::Triangle

