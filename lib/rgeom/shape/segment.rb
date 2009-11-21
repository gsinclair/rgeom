# *---------------------------------------------------------------------------*
# *                                                                           *
# *  Table of Contents                                                        *
# *                                                                           *
# *  -1  -Segment (general)                                                   *
# *  -2  -Data (Segment::Data)                                                *
# *  -3  -Parse (Segment.parse_specific)                                      *
# *  -4  -Construct (Segment.construct)                                       *
# *                                                                           *
# *---------------------------------------------------------------------------*

# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -1  -Segment (general)                                                   *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom
  
    # Segments have a start and end point, called _p_ and _q_ in the code for short.
    # They are immutable once created (for now anyway...)
  class Segment < Shape

    CATEGORY = :segment

    def initialize(vertices)
      super(vertices)
      @p, @q = vertices.points
      # TODO Error if @p or @q is nil.
      @length, @angle = Point.relative(p, q).polar
    end

    attr_reader :label
    attr_reader :p, :q
    attr_reader :length, :angle
    attr_reader :vertices   # This is just to comply with Register#store; I'd happily
                            # get rid of it.  It should be in Shape, anyway.

    def Segment.simple(p, q)
      vl = VertexList.new(2, nil, [p,q])
      Segment.new(vl)
    end

    def to_s(format=:ignore)
      "Segment #{@label}: #{@p} #{@q}"
    end
    def inspect; to_s; end

    def Segment.[](n)
      @@register.nth(:segment, n)
    end

      # Returns the same segment as this one, but with the vertices in the opposite
      # order.  That can be useful for constructing shapes, as order is important for
      # anti-clockwise construction.
    def reverse
      segment(:start => @q, :end => @p, :draw => false)
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
      Segment.simple(start, target)
    end

  end  # class Segment

end  # module RGeom




# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -2  -Data (Segment::Data)                                                *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom
  class Segment::Data < Shape::Data
    fattr :p, :q, :move, :r, :th
    def to_s
      return %{
        <segment_data>
          label         #{label.inspect}
          vertex_list   #{vertex_list.inspect}
          p             #{p.inspect}
          q             #{q.inspect}
          move          #{move.inspect}
          r             #{r.inspect}
          th            #{th.inspect}
          unprocessed   #{unprocessed.inspect}
        </segment_data>
      }.trim
    end
  end  # class Segment::Data
end  # module RGeom



# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -3  -Parse (Segment.parse_specific)                                      *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom; class Segment

  def Segment.label_size; 2; end

  def Segment.parse_specific(a, label)
    p        = a.extract(:start, :p)
    q        = a.extract(:end, :q)
    move     = a.extract(:move)
    r        = a.extract(:r)
    th       = a.extract(:th)

    vertex_list = VertexList.resolve(2, label)
    if Symbol === p then p = @@register[p] end
    if Symbol === q then q = @@register[q] end
    vertex_list.accommodate [p, q]

    { :vertex_list => vertex_list,
      :p => p, :q => q, :move => move, :r => r, :th => th }
  end  # Segment.parse

end; end  # module RGeom; class Segment


# *---------------------------------------------------------------------------*
# *                                                                           *
# *  -4  -Construct (Segment.construct)                                       *
# *                                                                           *
# *---------------------------------------------------------------------------*

module RGeom

  class Segment::Constructor
    def initialize(data)
      @data = data
    end

    def construct
      case @data.vertex_list.mask
      when "TT"
        # Nothing to be done.
      when "TF"
        # @q = construct_second_point
        # We'll implement the above later.  Only dealing with simple segments for now.
        Err.incompletely_defined_segment(data.label)
      when "FF"
        Err.incompletely_defined_segment(data.label)
      end
      Segment.new(@data.vertex_list)
    end

    def construct_second_point
    end

  end  # class Segment::Constructor

end  # module RGeom
