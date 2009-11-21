
# *---------------------------------------------------------------------------*
# *                                                                           *
# *  Table of Contents                                                        *
# *                                                                           *
# *  -1  -Square (general)                                                   *
# *  -2  -Data
# *  -3  -Parse                                                               *
# *  -4  -Construct                                                           *
# *                                                                           *
# *---------------------------------------------------------------------------*

# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -1  -Square (general)                                                   *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom
  
    # Squares have four vertices.
  class Square < Shape

    CATEGORY = :square

    def initialize(vertices)
      super(vertices)
      # TODO @base = Segment.unregistered(first two points in vertices)
      @base = segment(:p => pt(0), :q => pt(1))
      @side = @base.length
    end

    attr_reader :side

    def to_s(mode=:long)
      label = @label || "(no label)"
      if mode == :short
        "Square #{label} " + @points.map { |p| p.to_s(1) }.join(" ")
      elsif mode == :long
        "Square #{label}:\n  ".green.bold + @vertices.to_s(:long)
      else
        Err.invalid_display_mode(mode)
      end
    end
    def inspect; to_s(:short); end
    def label; @label; end

    def diagonals
    end

  end  # class Square

end  # module RGeom

# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -2  -Data                                                                *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom
  class Square::Data < Shape::Data
    fattr :side, :base
    def to_s(format=:long)
      if format == :short
        "label: #{label.inspect}  side: #{side}  "
      else
        return %{
          <circle_data>
            label         #{label.inspect}
            vertex_list   #{vertex_list.inspect}
            side          #{side.inspect}
            base          #{base.inspect}
            givens        #{givens.inspect}
            unprocessed   #{unprocessed.inspect}
          </circle_data>
        }.trim.tabto(0)
      end
    end
  end  # class Square::Data
end  # module RGeom



# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -3  -Parse                                                               *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom; class Square

    # _a_ : ArgumentProcessor
    #
    # This method parses the arguments that are specific to a square.  It
    # returns a Hash that can be merged with the generic Shape data.
  def Square.parse_specific(a, label)
    vertex_list = VertexList.resolve(4, label)
    side        = a.extract(:side)
    base        = a.extract(:base)
    { :vertex_list => vertex_list, :side => side, :base => base }
  end

  def Square.label_size; 4; end

end; end  # class RGeom::Square


# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -4  -Construct                                                           *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom
  class Square::Constructor
    DEFAULT_SIDE = 5

    def initialize(data)
      @data = data
      @register = RGeom::Register.instance
    end

      # square :ABCD   where A and B are defined
      # square :ABCD   where A is defined (or defaults to origin)
      # square :AB__   where A and B are defined
      # square :ABCD, :side => 10   where A is defined (or defaults to origin)
      # square :base => :CD
      # square :base => some_segment
    def construct
      base, side = @data.values_at(:base, :side)
      scale, angle, vector = nil
      check_specification_integrity
      incorporate_base_specification
        # ^ This will update @data.vertex_list if given, e.g., :base => :XY
      a, b, c, d = @data.vertex_list.points
      case @data.vertex_list.mask
      when /TT../
        scale, angle = Point.relative(a, b).polar
        vector = a
      when /T.../, /..../
        scale = @data.side || DEFAULT_SIDE
        angle = 0
        vector = a || Point[0,0]
      end
      points = unit_square.transform(scale, angle, vector)
      @data.vertex_list.accommodate(points)
      Square.new(@data.vertex_list)
    end

    def unit_square
      @unit_square ||= PointList[[0,0], [1,0], [1,1], [0,1]]
    end

    def check_specification_integrity
      if @data.base? and @data.side?
        Err.invalid_square_spec(@data, ":base and :side both specified")
      elsif @data.vertex_list.mask =~ /TTT./
        Err.invalid_square_spec(@data, "Too many points specified")
      elsif @data.base? and @data.label?
        Err.invalid_square_spec(@data, ":base and label specified")
      end
    end
    private :check_specification_integrity

    def incorporate_base_specification
      if base = @data.base?
        points =
          case base
          when Segment
            base.points
          when Symbol
            VertexList.resolve(2, base).points
          else
            Err.invalid_square_spec(@data, "Invalid value for base: #{base.inspect}")
          end
        @data.vertex_list.accommodate(points)
      end
    end
    private :incorporate_base_specification

  end  # class Square::Constructor

end  # module RGeom

