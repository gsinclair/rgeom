
module RGeom::Shapes
  class Circle < RGeom::Shape

    # *------------------* Circle construction code *------------------* 

    def self.construct(spec)
      angle = 0.d          # Angle of radius; think circle(:radius => :AB)
                           # TODO: when Circle < Arc, this won't be necessary
      centre, radius =
        case spec.parameters
        when [:centre, :radius]          # point, length
          [spec.centre, spec.radius]
        when [:centre, :diameter]        # point, length
          [spec.centre, spec.diameter.to_f/2]
        when [:radius]                   # segment
          segment = spec.radius
          angle = segment.angle
          [segment.p, segment.length]
        when [:diameter]                 # segment
          segment = spec.diameter
          angle = segment.angle
          [segment.midpoint, segment.length.to_f/2]
        end
      Circle.new(spec.label, centre, radius, angle)
    end

    # *------------------* General circle code *------------------* 

    def initialize(label, centre, radius, angle=0.d)
      super(nil, label)
      @centre, @radius = centre, radius
      @angle_of_radius = angle
    end

    attr_reader :label
    attr_reader :centre, :radius

    require 'rgeom/shapes/x/circle_arc_common'
    include CircleArcCommon

    def to_s(format=:ignore)
      if @label
        "Circle #{@label.inspect}: #{@centre.to_s(1)} r=#{@radius}"
      else
        "Circle: #{@centre.to_s(1)} #{@radius}"
      end
    end
    def inspect; to_s; end

    # The calculation of a circle's bounding box is different for polygonal shapes.
    def bounding_box
      r = @radius
      bottom_left = Point[@centre.x - r, @centre.y - r]
      top_right   = Point[@centre.x + r, @centre.y + r]
      [bottom_left, top_right]
    end

    def tangent_from_external_point(point, n)
      # n is 1 or 2, as there are two tangents
    end

    # This is an esoteric method designed entirely to assist the
    # implementation of arcs.  A circle and arc may be specified like this:
    #
    #   circle :diameter => :AC
    #   arc    :diameter => :AC, :angles => [45,100]
    #
    # In the case of the arc, the angles 45 and 100 degrees are _relative_ to
    # the segment AC.  The Arc class needs the angle that AC makes so it can
    # offset the angles 45 and 100.
    # 
    # Since Arc relies on Circle to understand the <tt>:diameter => :AC</tt>
    # part, that information is lost by the time it gets to Arc.  That's why
    # this method exists.
    def angle_of_specified_radius
      @angle_of_radius
    end

  end  # class Circle
end  # module RGeom::Shapes

