
module RGeom::Shapes
  
  # *------------------* General square code *------------------* 

  class Square < RGeom::Shape

    def self.construct(spec)
      Constructor.construct(spec)
    end


    def initialize(vertices)
      super(vertices)
      @side = Segment.simple( pt(0), pt(1) ).length
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

    def diagonals
    end

  end  # class Square

  # *------------------* Square construction code *------------------* 

  class Square
    class Constructor
      DEFAULT_SIDE = 5

        # Cases:
        #   square :ABCD                (where A is defined or defaults to origin)
        #   square :ABCD, :side => 10   (where A is defined or defaults to origin)
        #   square :side => 10          (label permitted; see above)
        #   square :ABCD                (where A and B are defined)
        #   square :base => :CD         (no label permitted)
        #   square :diagonal => :XY     (no label permitted)
      def Constructor.construct(spec)
        v = VertexList.resolve(4, spec.label)
        a, b, c, d = v.points
        mask = v.mask
        m = lambda { |obj,chr| obj ? chr : "_" }
        supermask = m[spec.label,'L'] + mask + m[spec.side,'s'] +
                    m[spec.base,'b'] + m[spec.diagonal,'d']
          # Supermask where everything is defined:    LTTFFsbd
          # Supermask with no label but base defined: _FFFF_b_
        vector, angle, scale = nil
        case supermask
        when /_FFFF___/
          #   square                      (no label, no parameters, nothing)
          vector = Point[0,0]
          angle  = 0.d
          scale  = DEFAULT_SIDE
        when /L.FFF.__/
          #   square :ABCD                (where A is defined or defaults to origin)
          #   square :ABCD, :side => 10   (where A is defined or defaults to origin)
          vector = a || Point[0,0]
          angle = 0.d
          scale = spec.side || DEFAULT_SIDE
        when /LTTFF___/
          #   square :ABCD                (where A and B are defined)
          scale, angle = Point.relative(a, b).polar
          vector = a
        when /_FFFFs__/
          #   square :side => 10          (label permitted; see above)
          vector = Point[0,0]
          angle  = 0.d
          scale  = spec.side
        when /_FFFF_b_/
          #   square :base => :CD         (no label permitted)
          #     The :base argument actually comes to us as a Segment.  We will
          #     use the points and ignore the label.
          vector = spec.base.p
          angle  = spec.base.angle
          scale  = spec.base.length
        when /_FFFF__d/
          #   square :diagonal => :XY     (no label permitted)
          vector = spec.diagonal.p
          angle  = spec.diagonal.angle
          scale  = spec.diagonal.length
          points = unit_diagonal_square.transform(scale, angle, vector)
          v.accommodate(points)
            # Diagonal is a special case; we return the square ourselves.
          return RGeom::Shapes::Square.new(v)
        else
          Err.invalid_square_spec(spec, "invalid combination of arguments")
        end
          # Take the scale, angle and vector we've determined and create the square.
        points = unit_square.transform(scale, angle, vector)
        v.accommodate(points)
        RGeom::Shapes::Square.new(v)
      end

      def Constructor.unit_square
        @unit_square ||= PointList[[0,0], [1,0], [1,1], [0,1]]
      end

      def Constructor.unit_diagonal_square
        @unit_diagonal_square ||= PointList[[0,0], [0.5,-0.5], [1,0], [0.5,0.5]]
      end
    end  # class Constructor
  end  # class Square

end  # module RGeom::Shapes
