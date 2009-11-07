# This file concerns itself with parsing the specification of a triangle.

# *---------------------------------------------------------------------------*
# *                                                                           *
# *  Table of Contents                                                        *
# *                                                                           *
# *  -1  -Data (Triangle::Data)                                               *
# *  -2  -Parse (Triangle.parse_specific)                                     *
# *                                                                           *
# *---------------------------------------------------------------------------*


# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -1  -Data (Triangle::Data)                                               *
# *                                                                           *
# *---------------------------------------------------------------------------*


module RGeom
  class Triangle::Data < Shape::Data
    fattrs :type, :base, :height, :angles, :sides, :right_angle, :sas
    alias side sides
    alias angle angles
    def to_s(format=:ignored)
      return %{
        <triangle_data>
          label         #{label.inspect}
          vertex_list   #{vertex_list.to_s(:short)}
          type          #{type.inspect}
          base          #{base.inspect}
          height        #{height.inspect}
          angle(s)      #{angles.inspect}
          side(s)       #{sides.inspect}
          right_angle   #{right_angle.inspect}
          sas           #{sas.inspect}
          unprocessed   #{unprocessed.inspect}
        </triangle_data>
      }.trim
    end
  end  # class Triangle::Data
end  # module RGeom




# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -2  -Parse (Triangle.parse_specific)                                     *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom; class Triangle

  def Triangle.label_size; 3; end

    # See Shape.parse_specific
  def Triangle.parse_specific(a, label)
    vertex_list = VertexList.resolve(3, label)
    type   = a.extract(:equilateral, :isosceles, :scalene)
    base   = a.extract(:base)
    height = a.extract(:height)
    angles = a.extract(:angles, :angle)
    sides  = a.extract(:sides, :side)
    sas    = a.extract(:sas)

    if a.contains?(:right_angle)
      raise ArgumentError unless type.nil?
      type = :right_angle
      right_angle = a.extract(:right_angle)
    end

    case base      # Base will be interpreted as a length.  If it was used to specify
    when Numeric   # an interval or a couple of points, we need to process it.
      # Nothing to see here...
    when nil
      # That's OK too.
    when Symbol
      # triangle(:base => :AC, ...)
      vertex_names = base.split
      points = @@register.retrieve_points(vertex_names) + [nil]
      vertex_list.accommodate(points)
      base = nil
    when Array
      # triangle(:base => [p(5,3), p(-1,2)], ...)
      points = base + [nil]
      vertex_list.accommodate(points)
      base = nil
    when Segment
      points = [base.p, base.q, nil]
      vertex_list.accommodate(points)
    else
      Err.invalid_base_spec(base)
    end

    # type = :scalene if type.nil?
    # ^^^^ No default type.  If none is provided, we work out what's required
    # from the other information.
    # 
    # If triangle(:ABC), then maybe all points are known. 
    # If triangle(:ABC, :sides => [4,6,5]), then there's the info to create it.

    {
      :vertex_list => vertex_list, :type => type,
      :base => base, :height => height, :angles => angles, :sides => sides,
      :right_angle => right_angle, :sas => sas,
    }
  end  # Triangle.parse

end; end  # module RGeom; class Triangle


