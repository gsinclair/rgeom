require 'facets/dictionary'

module RGeom::Support

  class Specification

    @@register = RGeom::Register.instance

      # E.g.
      #   Specification.new(:triangle, a) do |s|
      #     s.resolve_vertex_list(:ABC)
      #     s.extract(:base, :height, :angle)
      #   end
    def initialize(arg_processor)
      @ap   = arg_processor
      @data = Dictionary.new
      process_data(:label, nil)   # default value for label
      yield self
    end

    attr_reader :ap
    def args; @ap.args; end

    def values_at(*keys)
      keys.map { |k| @data[k] }
    end

    def to_s(format=:short)
      case format
      when :short
        "Specification: #{@data.inspect}"
      when :long
        @length ||= @data.keys.map { |k| k.to_s.length }.max
        "Specification:\n" + @data.map { |k,v|
          "  %-*s   %s\n" % [@length, k, v.inspect] }.join
      else
        raise "Invalid format: #{format}"
      end
    end

      # Sets @data[:vertex_list] to a VertexList object based on the given label.
    def resolve_vertex_list(n, label=nil)
        # TODO is the label parameter necessary, given that the object is
        #      initialised with one?
      label ||= @ap.extract_label(n)
      process_data :label, label
      process_data :vertex_list, VertexList.resolve(n, label)
    end

      # e.g.
      #   s.resolve_points(:p, :q)
      # Does the following things:
      # * Checks whether s.p and s.q are symbols.
      # * Updates s.p and s.q based on the register.
      # * Calls vertex_list.accommodate
    def resolve_points(*symbols)
      #debugger if $test_unit_current_test =~ /2/
      symbols.each do |symbol|
        debug "*** #{symbol.inspect}"
        getter = self.method(symbol)
        setter = self.method(symbol.to_s + "=")
        if Symbol === getter.call
          point = @@register[getter.call]
          error "Point #{getter.call} not defined" if point.nil?
          setter.call(point)
        end
      end
      points = symbols.map { |s| self.send s }
      self.vertex_list.accommodate points
    end

      # Shortcut for <tt>s.vertex_list.accommodate points</tt>
    def accommodate(points)
      self.vertex_list.accommodate points
    end

##  TODO Shouldn't need this code now; just use Err.invalid_spec.
##  def error_method=(sym)
##    @error_method = sym
##  end

    def unprocessed=(value)   # TODO not sure about this
      @data[:unprocessed] = value
    end

    def unprocessed
      @data[:unprocessed]
    end

    def extract(*args)
      args.each do |arg|
        process_data( arg, @ap.extract(arg) )
      end
      args.map { |a| self.send(a) }.return_value
    end

    # E.g.
    #   s.extract_one(:type, [:equilateral, :isosceles, :scalene])
    #   s.type   # :isosceles
    def extract_one(key, matches)
      match = matches.find { |a| @ap.contains? a }
      process_data key, @ap.extract(match)
    end

    # E.g.
    #   # Given args :side => 4, :base => 3, :colour => :red ...
    #   s.extract_one_alias(:sides, :side)
    #   s.sides  == 4
    #   s.side   == 4
    #   s.side?  == true
    #   s.sides? == true
    #
    # Error is raised if both :sides AND :side are specified.
    def extract_one_alias(k1, k2)
      v1 = @ap.extract(k1)
      v2 = @ap.extract(k2)
      if v1 and v2
        error "#{k1} and #{k2} both specified"
      end
      value = v1 || v2      # At least one of them is nil.
      process_data k1, value
      create_alias k2, k1
        # TODO the above two lines mean that both @side and @sides (for example)
        #      are set.  That's not ideal.  It should be a true alias situation.
        #      Revisit.
    end

    # E.g.
    #   # Given args: :sides => [4,7], :base => 5, :angle => 45.d
    #   s.extract_alias([:sides, :side], [:angles, :angle])
    #   s.sides  == [4,7]
    #   s.side   == [4,7]
    #   s.angles == 45
    #   s.angle  == 45
    def extract_alias(*args)
      args.each do |k1,k2|
        # k1 and k2 are potential keys to extract
        extract_one_alias(k1, k2)
      end
    end

    def exactly_one(*keys)
      unless keys.one? { |k| @data.key? k }
        error "Only one of #{keys.inspect} is allowed to be specified"
      end
    end

    def type_check(key, *classes)
      unless classes.any? { |c| key.kind_of? c }
        error "#{key.inspect} must be of type #{classes.inspect}"
      end
    end

    def default(key, value)   # Not sure about this
      @data[key] ||= value
    end

    def to_hash
      @data.dup
    end

    private

    def process_data(key, value)
      @data[key] = value
      create_methods(key)
    end

      # E.g.
      #   s.extract(a, :base, :height)
      #   s.base
      #   s.height
      #   s.length     # Error: no method
      #   s.base?      # true
      #   s.length?    # false
      #   s.length = 5
      #   s.length?    # true
    def create_methods(sym)
      getter = sym
      define_method(getter) do
        @data[sym]
      end
      setter = sym.to_s + "="
      define_method(setter) do |value|
        @data[sym] = value
      end
      query = sym.to_s + '?'
      define_method(query) do
        @data[sym].not_nil?
      end
    end

    # E.g.
    #   create_alias(:side, :sides)   # side() is an alias for sides()
    #                                 # likewise sides?()
    def create_alias(side, sides)
      getter_target = side
      getter_source = sides
      define_method(getter_target) do
        self.send getter_source
      end
      query_target = side.to_s + '?'
      quert_source = sides.to_s + '?'
      define_method(query_target) do
        self.send quert_source
      end
    end

    def error(msg)
      Err.invalid_spec(@shape, self, msg)
    end

    def error_method
      Err.method(@error_method || :specification_error)
    end

  end  # class Specification

end  # module RGeom::Support

