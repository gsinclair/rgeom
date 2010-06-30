
  # RGeom::Shape acts as a base class for Segment, Triangle, Quadrilateral, Circle, etc.
  # What do these things have in common?
  #  * A list of vertices (VertexList)
  #  * A bounding box
  #  * The need to process varied arguments
  #  * The idea of constructing something
  #  * The need to maintain a (common) register of points etc.
  #  * A style with which they are drawn (colour, line thickness etc.)
module RGeom
  class Shape

      # Shape.create is the engine behind the user-level methods like
      # circle(...), segment(...), etc.
    def Shape.create(*args)
      debug "#{self}::create(#{args.inspect})"
      #debugger if $test_unit_current_test =~ /comma/
      spec = self.shape_properties.generate_construction_spec(args)
      debug spec if $test_unit_current_test =~ /comma/
      self.construct(spec)
    end

      # To be implemented for each subclass.  Called by :create above.
    def Shape.construct(spec)
      Err.not_implemented
    end

    #
    # The following things are a part of every Shape object.
    #
    # @@register  -- the place where points and shapes are stored
    # @vertices   -- a VertexList of the shape's vertices
    # @id         -- :seg03, :tri21, etc.
    # @style      -- a Style object for rendering
    #
    # Register-related methods:
    #   category      -- method that returns :triangle, :circle, etc.
    #   label         -- :ABC, :XY, :H, ... (may be nil)
    #   id            -- :seg03, :tri21
    #   style         -- a Style object for rendering
    #   style(...)    -- modify the style properties
    #
    # Geometrical methods:
    #   points        -- PointList containing the vertices (nil for circle)
    #   bounding_box  -- two points representing the bottom-left and top-right
    #   centroid      -- the middle of the shape
    #

    def initialize(vertices, label=nil)
      @vertices = vertices
      @label    = label || (vertices && vertices.label) || nil
    end

      # Add this shape to the register.
    def register
      @@register.store(self.category, self)
         # So Triangle gets stored as :triangle, Segment as :segment, etc.
      self
    end

    @@register = RGeom::Register.instance
    attr_reader :id, :label, :style
    attr_reader :vertices   # TODO: consider whether this should be here;
                            #       it's here to support methods like points, ...
    def category; Err.not_implemented; end
    #def label;    Err.not_implemented; end

      # A shape's id (:tri03 etc.) is set by the register upon entry.  That
      # a once-only operation.
    def id=(id)
      if @id.nil?
        @id = id
      else
        Err.attempt_to_set_id_a_second_time(self, id)
      end
    end

      # Triangle[3] retrieves the 4th triangle created, etc.
    def Shape.[](n)
      @@register.nth(self::CATEGORY, n)
    end

      # Circle.category returns :circle, etc.
    def category
      self.class::CATEGORY
    end

    def Shape.generate_1(n, first, &generator)
      object = first
      (n-1).times do
        object = generator[object]
      end
    end

      # _args_ is an array of lambdas, each of which generates an object based on the
      # previous one.  This allows you to generate a triangle, then circle, then square,
      # then triangle, then circle, then square, then ...
    def Shape.generate(n, first, *args, &block)
      Err.invalid_generator unless n.is_a? Integer and
        first.is_a? Shape and args.all? { |g| g.is_a? Proc }
      if args.empty?
        generate_1(n, first, &block)
      else
        object = first
        i = 1
        generators = (1..n).map { args }.flatten
        loop do
          object = generators.shift.call(object)
          i += 1
          return object if i >= n
        end
      end
    end

      # Shape objects are stored in the register.  In order to retrieve them, they need
      # to _match_ (===) the search key.  Shapes match other shape objects of the same
      # type if they are equal.  Shapes match symbols like :ABT if that is their label.
      #
      # TODO this method is a bit old and things have changed significantly in
      #      the register.  This method may not be needed anymore.
    def ===(arg)
      case arg
      when self.class
        # We have a type match.
        self == arg
      when Symbol
        # A label, like :ABT.
        self.label == arg and arg.to_s !~ /_/
      else
        raise ArgumentError,
          "Can only match Shape against another shape or a label (e.g. :ABT)"
      end
    end

      # 'style' is a reader _and_ writer method.
      #   t = triangle(:ABC, :equilateral).style(:dashed, :blue)   -> Triangle<...>
      #   t.style                                                  -> Style<...>
    def style(*args)
      if args.empty?
        @style
      else
        @style.apply(*args)
      end
    end

      # Default implementation of 'points' which will be sufficient for most
      # shapes.
    def points
      self.vertices.points
    end

      # Returns the nth point that defines this shape.  TODO: more efficient
      # implementation.
    def pt(n)
      points[n]
    end

    def each_vertex
      points.each do |pt|
        yield pt
      end
    end

      # Default implementation of bounding box which will be sufficient for most
      # shapes.
    def bounding_box
      self.vertices.pointlist.bounding_box
    end

      # Default implementation of centroid which will be sufficient for most
      # shapes.
    def centroid
      self.vertices.pointlist.centroid
    end

      # Next few methods awaiting implementation.
    def rotate(theta)
      self
    end

    def rotate_about(point, theta)
      self
    end

    def shift(vector)
      self
    end

    def xscale(k)
      self
    end

    def yscale(k)
      self
    end

    def scale(k)
      self
    end

    def reflect(line)
      self
    end

  end  # class Shape

end  # module RGeom
