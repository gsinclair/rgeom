
module RGeom::Shapes

  class Segment < RGeom::Shape

    def Segment.construct(spec)
      case spec.parameters
      when [:start, :end]
        Segment.simple(spec.start, spec.end)
      when [:p, :q]
        Segment.simple(spec.p, spec.q)
      when []
        Err.no_arguments_provided if spec.label.nil?
        Segment.from_symbol(spec.label)
      end
    end

    def initialize(vertices)
      super(vertices)
      @p, @q = vertices.points
      # todo: Error if @p or @q is nil.  (Done below; good enough? SpecificationError?)
      if @p.nil?
        raise ArgumentError, "starting point of segment is nil"
      elsif q.nil?
        raise ArgumentError, "finishing point of segment is nil"
      end
      @length, @angle = Point.relative(p, q).polar
    end

    def Segment.simple(p, q)
      vl = VertexList.new(2, nil, [p,q])
      Segment.new(vl)
    end

    def Segment.from_symbol(sym)
      v1 = VertexList.resolve(2, sym)
      unless v1.mask == "TT"
        Err.invalid_spec(:segment, sym, "Non-existent point")
      end
      Segment.new(v1)
    end

    attr_reader :label
    attr_reader :p, :q
    attr_reader :length, :angle
    attr_reader :vertices   # This is just to comply with Register#store; I'd happily
                            # get rid of it.  It should be in Shape, anyway.

    def to_s(format=:ignore)
      "Segment #{@label}: #{@p} #{@q}"
    end
    def inspect; to_s; end

    def ==(other)
      self.p == other.p and self.q == other.q and self.label == other.label
    end

    def start() @p end
    def end()   @q end

      # Returns the same segment as this one, but with the vertices in the opposite
      # order.  That can be useful for constructing shapes, as order is important for
      # anti-clockwise construction.
    def reverse
      Segment.simple(@q, @p)
    end

      # In segment AB:
      #   interpolate(0)    -> A
      #   interpolate(1)    -> B
      #   interpolate(0.5)  -> midpoint AB
      #   interpolate(1.8)  -> somewhere beyond B
      #   interpolate(-3)   -> somewhere behind A
    def interpolate(k)
      x1, y1, x2, y2 = @p.x, @p.y, @q.x, @q.y
      x = x1 + k*(x2 - x1)
      y = y1 + k*(y2 - y1)
      Point[x,y]
    end
    alias interp interpolate

    def midpoint
      centroid
    end

      # Related to interpolate.  This method creates a new segment as an extension of
      # the existing one.  E.g.
      #
      #   segment(:DE).extend(1.7, :F, :dotted)
      #
      # That will create point F (optional) and put a dotted segment between E and F.
      # A negative interpolation would start the extension at D.  :dotted is not yet
      # implemented; that's what the extra <tt>*args</tt> is for.
    def extend(k, label=nil, *args)
      if k.in? 0..1
        warn "Argument to Segment#extend must be outside the range 0..1.  Ignoring."
        return self
      end
      target = interpolate(k)
      if label.not_nil?
        @@register[label] = target
      end
      start = (k < 0) ? @p : @q
      Segment.simple(start, target).register
    end

  end  # class Segment
end  # module RGeom::Shapes

