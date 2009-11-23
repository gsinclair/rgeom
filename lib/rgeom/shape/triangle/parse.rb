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

    # This method parses the arguments that are specific to a triangle.
    # The specification comes preloaded with the label and the vertex list.
    #   @s : Specification
    #   @a : ArgumentProcessor
    #   @return : Nothing important; it modifies _s_.
  def Triangle.parse_specific(s)
    s.extract_one(:type, [:equilateral, :isosceles, :scalene])
    s.extract(:base, :height, :sas)
    s.extract_alias([:sides, :side], [:angles, :angle])
    if s.extract(:right_angle)
      Err.invalid_spec(:triangle, s, ":#{s.type} and :right_angle") if s.type?
      s.type = :right_angle
    end

      # s.base will be interpreted as a length.  If it was used to specify an
      # interval or two points, we need to process it.
      # TODO this should be moved to a different method (post_parse or something)
    case s.base
    when Numeric, nil
      # Nothing to do.
    when Symbol
      # triangle(:base => :AC, ...)
      points = @@register.retrieve_points(s.base.split)
      s.accommodate points
      s.base = nil
    when Array
      # triangle(:base => [p(5,3), p(-1,2)], ...)
      points = s.base + [nil]
      s.accommodate(points)
      s.base = nil
    when Segment
      points = [s.base.p, s.base.q, nil]
      s.accommodate(points)
    else
      Err.invalid_base_spec(base)
    end
    # TODO: when the DSL is implemented, we will have
    #   shape :triangle, :label_size => 3, :base => 'Num,Seg', ...
    # and the 'Seg' part will take care of the above code.

    # type = :scalene if type.nil?
    # ^^^^ No default type.  If none is provided, we work out what's required
    # from the other information.
    # 
    # If triangle(:ABC), then maybe all points are known. 
    # If triangle(:ABC, :sides => [4,6,5]), then there's the info to create it.
  end

end; end  # module RGeom; class Triangle


