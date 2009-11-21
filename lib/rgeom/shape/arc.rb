# *---------------------------------------------------------------------------*
# *                                                                           *
# *  Table of Contents                                                        *
# *                                                                           *
# *  -1  -Arc (general)                                                       *
# *  -2  -Data                                                                *
# *  -3  -Parse                                                               *
# *  -4  -Construct                                                           *
# *                                                                           *
# *---------------------------------------------------------------------------*

# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -1  -Arc (general)                                                       *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom
  
    # Arcs have a centre and radius.
  class Arc

    CATEGORY = :arc

    def initialize(label, centre, radius, angles, angle_offset=0)
      super(nil, label)
      Err.invalid_arc_no_angles if angles.blank?
      @centre = centre
      @radius = radius
      @angles = _normalise(angles)
      @angle_offset = angle_offset    # Where does the 'zero' angle really start?
      @absolute_angles = @angles.map { |a| a + @angle_offset }
    end

    attr_reader :centre, :radius, :angles, :angle_offset

    require 'rgeom/shape/circle/circle_arc_common'
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
      a1, a2 = absolute_angles
      range = (a1..a2)
      extremities = [0, 90, 180, 270]
      relevant_extremities = extremities.select { |a| range.include? a }
      bounding_points = (relevant_extremities << a1 << a2).map { |angle| point(angle) }
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

    # arc(:angles => [45,190]).contains? 50     # true
    # arc(:angles => [45,190]).contains? 40     # false
    def contains?(angle)
      angle = angle % 360
      (@angles[0]..@angles[1]).contains? angle
    end

      # [310,195] becomes [-50,195].  We want the first one to be smaller than
      # the second one, and we want the difference (which is the centre angle) to
      # be <= 360 degrees.  Finally, we ensure that the angles are not too far
      # from zero by doing "mod 360" up front.
    def _normalise(angles)
      a1, a2 = angles.map { |a| a % 360 }
      while a1 > a2
        a1 -= 360
      end
      [a1, a2]
    end
    private :_normalise

  end  # class Arc

end  # module RGeom

# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -2  -Data                                                                *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom
  class Arc::Data < Circle::Data
    fattr :angles
    def to_s(format=:long)
      if format == :short
        "label: #{label.inspect}  centre: #{centre}  " +
          "radius: #{radius}  diameter: #{diameter}  angles: #{angles}"
      else
        return %{
          <arc_data>
            label         #{label.inspect}
            vertex_list   #{vertex_list.inspect}
            centre        #{centre.inspect}
            radius        #{radius.inspect}
            diameter      #{diameter.inspect}
            angles        #{angles.inspect}
            givens        #{givens.inspect}
            unprocessed   #{unprocessed.inspect}
          </arc_data>
        }.trim.tabto(0)
      end
    end
  end  # class Arc::Data
end  # module RGeom



# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -3  -Parse                                                               *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom; class Arc

    # _a_ : ArgumentProcessor
    #
    # This method parses the arguments that are specific to a arc.  It
    # returns a Hash that can be merged with the generic Shape data.
  def Arc.parse_specific(a, label)
    angles = a.extract(:angles)
    Circle.parse_specific(a, label, angles)
  end

  def Arc.label_size; 1; end

end; end  # class RGeom::Arc


# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -4  -Construct                                                           *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom
  class Arc::Constructor
    def initialize(data)
      @data = data
      @register = RGeom::Register.instance
    end

      # To construct an arc, we create a circle from the data we have (Arc::Data
      # is a superset of Circle::Data).  We don't have to do the complicated
      # parsing; we just use the centre and radius that it determines.
    def construct
      circle = RGeom::Circle.construct(@data.dup)
      circle.deregister
        # ^ We create a circle to deal with the stuff like :radius => :AB
      Arc.new(@data.label, circle.centre, circle.radius,
              @data.angles, circle.angle_of_specified_radius_in_degrees)
    end

  end  # class Arc::Constructor

  def Arc.construct(data)
    debug data
    Arc::Constructor.new(data).construct
  end
end

