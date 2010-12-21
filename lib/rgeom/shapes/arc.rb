module RGeom::Shapes

  class Arc

    # *------------------* Arc construction code *------------------* 

    def self.construct(spec)
      debug spec
      circle_spec = spec.sans(:angles, :from, :to)
      circle = Circle.construct(circle_spec)
      angles = _determine_arc_angles(spec)
      Arc.new(circle, angles)
    end

    def self._determine_arc_angles(spec)
      if spec.parameters.include? :angles
        spec.angles
      elsif spec.parameters.include? :from
        pt1, pt2 = spec.from, spec.to   # Points
        angle1 = Point.relative(@centre, pt1)
        angle2 = Point.relative(@centre, pt2)
        [angle1, angle2]    # todo: how the hell does this work?  does it?
      end
    end

    # *------------------* General arc code *------------------* 

    CATEGORY = :arc

    attr_reader :label
    attr_reader :centre, :radius, :angles, :angle_offset

    def initialize(circle, angles)
      @label = circle.label
      @centre = circle.centre
      @radius = circle.radius
      # @angle_of_radius = circle.angle_of_radius    ????
      @angles = _normalise(angles)
      @angle_offset = circle.angle_of_specified_radius
        # ^^^ Where the 'zero' angle really starts.
      @absolute_angles = @angles.map { |a| a + @angle_offset }
    end

    require 'rgeom/shapes/x/circle_arc_common'
    include CircleArcCommon

    def to_s(format=:ignore)
      angles = @angles.inspect
      if @label
        "Arc #{@label.inspect}: #{@centre.to_s(1)} r=#{@radius} #{absolute_angles}"
      else
        "Arc: #{@centre.to_s(1)} #{@radius} #{absolute_angles}"
      end
    end
    def inspect; to_s; end

      # The calculation of an arc's bounding box is a special case, even more
      # so than a circle.
    def bounding_box
      # There are six potential extreme points in an arc: the place on the
      # circle at 0, 90, 180 and 270 degrees, plus the two endpoints of the arc.
      # To find the bounding box, compile the list of the potential extremities
      # that actually exist on the arc, then call PointList#bounding_box on
      # those points.
      a1, a2 = absolute_angles.map { |a| a.deg }
      range = (a1..a2)
      extremities = [0, 90, 180, 270]
      relevant_extremities = extremities.select { |a| range.include? a }
      bounding_points = (relevant_extremities << a1 << a2).map { |angle| point(angle.d) }
      PointList[*bounding_points].bounding_box
    end

      # An arc doesn't have a centroid as it is not a closed shape.  We could, I
      # suppose, assume it is bounded by two radii and somehow calculate the
      # centre, but we'll wait until there's a need for that.
    def centroid
      nil
    end

      # The point that "begins" the arc.
    def start() interpolate(0) end
      # The point that "ends" the arc.
    def end()   interpolate(1) end

      # _Relative_ angles base the zero angle on the radius vector (when the arc
      # is constructed).  This returns the values the arc was created with.
    def relative_angles() @angles end

      # _Absolute_ angles base the zero angle on the positive x-axis, as is
      # normal.  This method is important for rendering the arc.
    def absolute_angles() @absolute_angles end

    def centre_angle() @angles[1] - @angles[0] end
    alias theta centre_angle

    # arc(:angles => [45.d,190.d]).contains? 50.d     # true
    # arc(:angles => [45.d,190.d]).contains? 40.d     # false
    def contains?(angle)
      angle = angle.deg
      @angles[0].deg <= angle  and  angle <= @angles[1].deg
    end

      # [310,195] becomes [-50,195].  We want the first one to be smaller than
      # the second one, and we want the difference (which is the centre angle) to
      # be <= 360 degrees.  Finally, we ensure that the angles are not too far
      # from zero by doing "mod 360" up front.
    def _normalise(angles)
      a1, a2 = angles.map { |a| a.deg % 360 }
      while a1 > a2
        a1 -= 360
      end
      [a1.d, a2.d]
    end
    private :_normalise

  end  # class Arc
end  # module RGeom::Shapes

