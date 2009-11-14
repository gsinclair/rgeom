require 'rgeom/support/argument_processor'

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
      @@register.store(self.category, self)
         #                  ^^^^^^^^
         # So Triangle gets stored as :triangle, Segment as :segment, etc.
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

      # Helps to process the arguments like <tt>:base => :AC, :angle => 45</tt>, etc.
    def Shape.preprocess_arguments(args)
      yield ArgumentProcessor.new(args)
    end

      # Shape.parse provides the general parsing of shape data (label, unprocessed) and
      # calls parse_specific to get the details of the particular shape.
      # 
      # Returns a Triangle::Data or Segment::Data or ... suitable for use with
      # the construct() method.
    def Shape.parse(*args)
      preprocess_arguments(args) do |a|
        hash = Hash.new
        hash[:label] = a.extract_label(self.label_size)   # -> :H or :ABC or whatever
        hash.merge!    parse_specific(a, hash[:label])
                       # ^^ gather the specifications for this specific shape
        #hash[:givens] = a.givens(self.givens_keys)
        hash[:unprocessed] = a.unprocessed

        data = (self)::Data.new(hash)
      end
    end

      # Each shape needs to parse its arguments in unique ways, but there is
      # common stuff too, like the label.  This method, implemented in Triangle,
      # Segment, etc., parses the stuff that is specific to that shape and
      # returns a hash of the things it's parsed.
      #
      # _a_ is an ArgumentProcessor; _label_ is :ABC or :XP__ or nil or
      # whatever.
    def Shape.parse_specific(a, label)
      raise "Not implemented in base class"
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




    # Used for parsing the arguments to triangle(), circle(), etc.
    # Subclassed by TriangleData, CircleData, etc.
    # What do they all have in common?
    #  * Label (:ZCL, :H, ...)
    #  * Vertex list
    #  * Unprocessed arguments
    #  * "Givens"
    #
    # The last two items haven't been used as yet, but it's easy to keep them.
  class Shape::Data
    fattr :label, :vertex_list, :unprocessed, :givens

    def initialize(hash)
      hash.each_pair do |k,v|
        send k, v
      end
    end
    def to_s(format=:long)
      raise "Not implemented (should be in subclass)"
    end
    def inspect; to_s; end
    def values_at(*args)
      args.map { |a| self.send a }
    end
  end  # class ShapeData

end  # module RGeom
