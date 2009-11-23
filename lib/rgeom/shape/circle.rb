# *---------------------------------------------------------------------------*
# *                                                                           *
# *  Table of Contents                                                        *
# *                                                                           *
# *  -1  -Circle (general)                                                    *
# *  -2  -Data                                                                *
# *  -3  -Parse                                                               *
# *  -4  -Construct                                                           *
# *                                                                           *
# *---------------------------------------------------------------------------*

# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -1  -Circle (general)                                                    *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom
  
    # Circles have a centre and radius.
  class Circle < Shape

    CATEGORY = :circle

    def initialize(label, centre, radius, angle=0)
      super(nil, label)
      @centre, @radius = centre, radius
      @angle_of_radius = angle
    end

    attr_reader :label
    attr_reader :centre, :radius

    require 'rgeom/shape/circle/circle_arc_common'
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
    def angle_of_specified_radius_in_degrees
      @angle_of_radius.in_degrees
    end

  end  # class Circle

end  # module RGeom

# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -2  -Data                                                                *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom
  class Circle::Data < Shape::Data
    fattr :centre, :radius, :diameter
    def to_s(format=:long)
      if format == :short
        "label: #{label.inspect}  centre: #{centre}  " +
          "radius: #{radius}  diameter: #{diameter}"
      else
        return %{
          <circle_data>
            label         #{label.inspect}
            vertex_list   #{vertex_list.inspect}
            centre        #{centre.inspect}
            radius        #{radius.inspect}
            diameter      #{diameter.inspect}
            givens        #{givens.inspect}
            unprocessed   #{unprocessed.inspect}
          </circle_data>
        }.trim.tabto(0)
      end
    end
  end  # class Circle::Data
end  # module RGeom



# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -3  -Parse                                                               *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom; class Circle

    # @s : Specification
  def Circle.parse_specific(s)
    s.extract :centre
    s.extract_alias [:radius, :r], [:diameter, :d]
    s.vertex_list = nil
  end

  def Circle.label_size; 1; end

end; end  # class RGeom::Circle


# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -4  -Construct                                                           *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom
  class Circle::Constructor
    def initialize(data)
      @data = data
      @register = RGeom::Register.instance
    end

    def construct
      centre, radius, diameter = @data.values_at(:centre, :radius, :diameter)
      angle = 0     # the angle of the radius (think :radius => :AC)
      mask = [centre, radius, diameter].map { |e|
        case e
        when nil     then '_'
        when Point   then 'P'
        when Numeric then 'N'
        when Symbol  then 'S'
        else              '?'
        end
      }.join

      valid_masks = %w{
        ___  _N_  __N
             _S_  __S  
        P__  PN_  P_N
        S__  SN_  S_N
             SS_  S_S
             PS_  P_S
      }

      Err.invalid_circle_spec(@data.to_s) unless valid_masks.include? mask
      check = lambda { |x,n|
        Err.invalid_circle_spec(@data.to_s(:short)) if x.length != n
      }

      case mask
      when "___"
        centre = p(0,0); radius = 1        # Default: unit circle
      when "_N_"
        centre = p(0,0)
      when "__N"
        centre = p(0,0); radius = diameter.to_f / 2.0
      when "_S_"
        check[radius,2]
        centre, radius, angle = parse_radius(radius)
      when "__S"
        check[diameter,2]
        centre, radius, angle = parse_diameter(diameter)
      when "P__"
        radius = 1
      when "PN_"    # Nothing to do.
      when "P_N"
        radius = diameter.to_f / 2.0
      when /S../
        check[centre,1]
        centre = @register[centre] or Err.nonexistent_centre(centre)
        case mask
        when "S__"
          radius = 1
        when "SN_"   # Nothing to do.
        when "S_N"
          radius = diameter.to_f / 2.0
        when "SS_"
          check[radius,2]
          _, radius, angle = parse_radius(radius)
        when "S_S"
          check[diameter,2]
          _, radius, angle = parse_diameter(diameter)
        end
      when "PS_"
        check[radius,2]
        _, radius, angle = parse_radius(radius)
      when "P_S"
        check[diameter,2]
        _, radius, angle = parse_diameter(diameter)
      end

      Circle.new(@data.label, centre, radius, angle)
    end

      # Return centre and radius, given symbol like :AB.
      # Centre is :A, radius is length of :AB.
    def parse_radius(radius)
      VertexList.resolve(2, radius).tap do |vl|
        Err.invalid_circle_spec(":radius => #{radius}") unless vl.mask == "TT"
        centre = vl[0]
        radius = Point.distance(vl[0], vl[1])
        angle = Point.angle(vl[0], vl[1])
        return [centre, radius, angle]
      end
    end

      # Return centre and radius, given symbol like :AB.
      # Centre is the midpoint of :AB, radius is half the length of :AB.
    def parse_diameter(diameter)
      VertexList.resolve(2, diameter).tap do |vl|
        Err.invalid_circle_spec(":diameter => #{diameter}") unless vl.mask == "TT"
        centre = Point.midpoint(vl[0], vl[1])
        radius = Point.distance(vl[0], vl[1]) / 2
        angle = Point.angle(vl[0], vl[1])
        return [centre, radius, angle]
      end
    end

  end  # class Circle::Constructor

end  # module RGeom

