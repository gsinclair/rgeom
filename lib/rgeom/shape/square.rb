
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

    attr_reader :base, :side

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
      # square :base => :CX
    def construct
      debug @data.to_s(:long)
      a, b, c, d = @data.vertex_list.points
      scale, angle, vector = nil
      case @data.vertex_list.mask
      when /TTTT/, /TTT./
        Err.invalid_square_spec
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

  end  # class Square::Constructor

  # TODO Implement this method once as Shape.construct.
  def Square.construct(data)
    Square::Constructor.new(data).construct
  end
end

