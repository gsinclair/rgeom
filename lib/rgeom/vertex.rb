
module RGeom

    # A vertex has a name and a location.  The name may be :_, meaning unnamed.
  class Vertex
    def initialize(name, point)
      @name = name || :_     # Maybe do :p5 etc. for "the 5th unnamed point"
      @point = point
    end
    def name; @name; end
    def point; @point; end
    def point=(point); @point = point; end
    def x; @point.x; end
    def y; @point.y; end
    def to_s; "#{@name} #{@point || '(nil)'}" end
    def inspect; to_s; end
    def ==(other)
      [self.name, self.point] == [other.name, other.point]
    end
    def hash() nil end
  end  # class Vertex




    #
    # VertexList has many responsibilities:
    #  * Record vertex names and their corresponding points.
    #  * Accommodate extra point information and raise an error if there's an
    #    inconsistency.
    #  * Produce a 'mask' (e.g. "TTF") to say which points are defined.
    #  * Provide convenient access to the vertex names, points and the label.
    #
    # Basically, a Shape has a VertexList as its most important defining property.  This
    # class has to make that part of it run smoothly.
    #
    # PointList currently handles translations, rotations, etc.  It would also be the
    # natural place to calculate centroids and possibly other things.  That class should
    # probably remain.  VertexList's responsbilities end when we're no longer concerned
    # about labels.
    #
    # Therefore VertexList can generate a PointList if anyone wants to do some
    # operations on the points.
    #
    # That may be a good idea, actually.  Since the list of points can change through
    # "accommodate", we have repeated code to maintain the point list.  Something to
    # think about in refactoring.
    #
    # == Usage
    #
    #   v1 = VertexList(4, :ABC_, [p(0,0), p(5,0), nil, nil])
    #     # VertexList:
    #     #   A (0,0)
    #     #   B (5,0)
    #     #   C (nil)
    #     #   _ (nil)
    #
    #   # At this point, the labels (A, B, C and _) are set in stone.  They are an
    #   # immutable property of the VertexList.  The points, however, can be updated.
    #
    #   v1.accommodate [nil, nil, p(5,5), p(0,5)]
    #     # VertexList:
    #     #   A (0,0)
    #     #   B (5,0)
    #     #   C (5,5)
    #     #   _ (0,5)
    #
    #   v2 = VertexList(4, :ABC_, [p(0,0), p(5,0), nil, nil])
    #     # Same as v1 created above.
    #
    #   vl[3] = p(9.4,-1)
    #     # VertexList:
    #     #   A (0,0)
    #     #   B (5,0)
    #     #   C (nil)
    #     #   _ (9.4,-1)
    #
    # The intention of a VertexList is that the points get set only once.  However,
    # since not all the points of a shape may be known initially, we have the facility
    # to initialise certain points to +nil+, then update them later.
    #
    # VertexList is closely tied to the Register, as it resolves points through
    # Vertex.resolve.  When you use Vertex.resolve or Vertex#accommodate or Vertex#[]=,
    # you are indirectly updating the register.
    #
  class VertexList
    @@register = RGeom::Register.instance

      # +names+: [:A, :B, :C] or [:G, :R, :_, :_] or [nil, nil, nil], or ...
      # +points+: array of Point objects (defaults to [nil, nil, ...])
    def initialize(n, names, points)
      @nvertices = n
      names = names || Array.new(n, nil);      _check_size(names)
      points = points || Array.new(n, nil);    _check_size(points)
      @vertices = (0...@nvertices).map { |i| Vertex.new(names[i], points[i]) }
      _check_invariant
      @label = label()
    end

      # Creates and returns a VertexList with the given vertex names and the points
      # that it can resolve from those names.  The return value may be...
      #
      #   VertexList:  A(5,3)  M(0,1)  G(-3,7)
      #   VertexList:  T(2,2)  X(nil)
      #   VertexList:  M(nil)  N(nil)
      #   VertexList:  nil(nil)  nil(nil)  nil(nil)  nil(nil)
      #
      # Vertices _named_ nil is not a problem; those vertices are simply anonymous
      # (although I may decide that they get a default label like :_ or :v07).
      # _Points_ with a nil value is a problem, though.  Points can be updated with the
      # VertexList#accommodate method.
    def VertexList.resolve(n, label)
      names, points = 
        if label.nil?
          [Array.new(n, :_), Array.new(n, nil)]
        else
          names = label.split
          # TODO ensure _n_ names; otherwise we can have :radius => :ABC
          points = names.map { |name| @@register[name] }
          [names, points]
        end
      VertexList.new(n, names, points)
    end

      # A vertex list may have been created with some of the points being +nil+.  That's
      # no good.  This method accepts an array of points that can slot in to this vertex
      # list.  An error is raised if a vertex is already properly defined and an attempt
      # is made to assign another point to it.
    def accommodate(points)
      if points.size > @nvertices
        Err.incorrect_number_of_vertices(@label, @nvertices, array.size)
      end
      (0...points.size).each do |i|
        self[i] = points[i]
      end
    end

      # _index_ must be a number.
      # You can only update a point if it is currently nil.
      # 
      #   vl = VertexList.resolve(3, :A__)         # (one point defined)
      #   vl[1] = p(4,2)      # fine  -- vl[1] was nil
      #   vl[1] = p(4,2)      # fine  -- setting it the same as before
      #   vl[2] = p(0,7)      # fine  -- vl[2] was nil
      #   vl[2] = p(-3,0)     # error -- vl[2] is already defined
    def []=(index, point)
      return if point.nil?
      vertex = @vertices[index]
      name  = vertex.name
      if vertex.point != nil and vertex.point != point
        Err.vertex_list_update_point(@label, index, vertex.point, point)
      end
      @vertices[index] = Vertex.new(name, point)
      @@register[name] = point   # Will cause an error if invalid update.
    end

      # list[2], not list[:C]. 
      # Returns a +Point+ object or +nil+.
      # TODO: it's a code smell not to be returning a vertex.  Consider use cases.
    def [](arg)
      case arg
      when Numeric
        @vertices[arg].point
      else
        raise ArgumentError, "Expected (Numeric)"
      end
    end

    def vertex(n)
      @vertices[n]
    end

    def to_s(mode=:long)
      case mode
      when :short
        "VertexList: ".green.bold + points().map { |v| v.to_s }.join(" ")
      when :long
        label = "VertexList #{label}:\n  ".green.bold
        vertices = @vertices.map { |v| v.to_s }
        label + vertices.join("\n  ")
      else
        Err.invalid_display_mode(mode)
      end
    end
    def inspect; to_s; end

    def vertex_names
      @vertices.map { |v| v.name }
    end

    def points
      @vertices.map { |v| v.point }
    end

    def pointlist
      PointList.new @vertices.map { |v| v.point }
    end

    def mask
      @vertices.map { |v| if v.point.not_nil? then 'T' else 'F' end }.join
    end

    def label
      if @label
        return @label
      else
        label = vertex_names.to_s
        if label == ""
          :___   # Think about making it the appropriate length, or even
        else     # ensuring the vertices are called :_ if they're not called anything else.
          label.to_sym
        end
      end
    end

    private
    def _check_size(array)
      if array.size != @nvertices
        Err.incorrect_number_of_vertices(@label, @nvertices, array.size)
      end
    end
    def _check_invariant
      # There should be the correct number of vertices and each one should be a
      # properly defined Vertex.  +nil+ is fine for label or point.
      _check_size(@vertices)
      Err.invalid_vertex_list unless @vertices.all? { |v| Vertex === v }
    end
  end  # class VertexList

end  # module RGeom
