
module RGeom; module DSL;

  # The 'shape' method is the heart of the "Shape DSL" which allows us to
  # specify the parameters that various shapes accept, and then get parameter
  # checking (including type checking) for free, saving a lot of boilerplate and
  # nuisance code, and making it much easier to implement the construction code
  # for shapes.
  #
  # Here is an example for a circle:
  #
  #   shape :circle, :label => :K,
  #     :parameters => %{
  #       centre: point=origin, radius: length=1
  #       centre: point=origin, diameter: length
  #       radius: segment
  #       diameter: segment
  #     }
  #
  # The <tt>:label => :K</tt> simply tells us that a circle's label is a single
  # capital letter.  You would write <tt>:label => "3+"</tt> for a polygon and
  # <tt>:label => nil</tt> for a histogram, say.
  #
  # The <tt>:parameters</tt> specification tells us what combination of
  # parameters the user can provide, what types they must be, and what the
  # default values are, if any.  Constraints can also be provided, e.g. for a
  # polygon, you must have at least three sides.
  #
  #   :parameters => %{
  #     n: integer(>=3)         # (other parameters elided)
  #   }
  # 
  # Here again is the circle spec:
  #
  #   shape :circle, :label => :K,
  #     :parameters => %{
  #       radius: segment
  #       diameter: segment
  #       centre: point=origin, radius: length=1
  #       centre: point=origin, diameter: length
  #     }
  #
  # This creates a top-level 'circle' method and a Circle class (to be precise,
  # <tt>RGeom::Shape::Circle</tt>).  Whoever is implementing circles needs to
  # write the method Circle#construct(data), where 'data' is a simple data
  # object containing the arguments that the user provided.
  #
  # The 'circle' method is called with keyword arguments.  Here are some valid
  # examples:
  #
  #   s = segment :p => p(4,5), :q => p(0,-2)
  #
  #   circle                                      # default centre and radius
  #   circle :radius => :CE                       # :CE cast to Segment object
  #   circle :diameter => s
  #   circle :centre => :X                        # :X cast to Point; default radius
  #   circle :radius => 5                         # default centre
  #   circle :centre => :Y, :radius => 2
  #   circle :centre => :Y, :diameter => 17
  #   circle :centre => :Y, :radius => :BC        # :BC cast to length
  #
  # If an _invalid_ argument set is provided, an error is automatically raised.
  #
  # Parameter sets are considered in the order in which they are specified, so
  # it's important to consider that when writing the specification, especially
  # given the possibility of default values.  For instance, the following line
  # can match _two_ of the parameter sets above:
  #
  #   circle :radius => :BC
  #
  # It matches the first spec and the third (with default centre).  The first
  # spec is the one we would want it to match; that's why it is listed first.
  #
  # You can *extend* shapes (i.e. inherit their parameters) like so:
  #
  #   shape :arc, :extends => :circle,
  #     :parameters => %{
  #       angles: [n,n]
  #     }
  #
  # TODO: support extensions; support the kind of conditional-parameter
  #       declarations needed by Triangle.
  #
  #       The alternative for Triangle is to have different classes behind the
  #       scenes (EquilateralTriangle, IsoscelesTrianlge, ...) and write a
  #       custom 'triangle' method that interfaces to all of them.  It's not
  #       nice, but neither is implementing the features in 'shape' that
  #       Triangle requires!  It's hard to imagine another shape being as
  #       complicated.
  #
  def shape(name, args={})
    # Assume name is :circle.
    label_size =
      case x = args[:label]
      when Symbol; x.to_s.size
      when String; x
      when nil; nil
      else
        Err.invalid_label_argument
      end
    raw_data = ShapeCommandRawData.new(args)
    begin
      debug "'shape' command called"
      debug "  name = #{name.inspect}"
      debug "  args = #{raw_data.inspect.indent(4)}"
    end if $debug_shape_command
    argument_parser = ArgumentParser.new(raw_data)
    properties = ShapeProperties.new( name, label_size, argument_parser )
    classname = name.to_s.titlecase
    eval %{
      class ::RGeom::Shapes::#{classname} < ::RGeom::Shape
        CATEGORY = #{name.inspect}
        def self.shape_properties
          @_properties ||= ShapeProperties[#{name.inspect}]
        end
      end

      module ::RGeom::Commands
        def _#{name}(*args)
          ::RGeom::Shapes::#{classname}.create(*args)
        end
        def #{name}(*args)
          _#{name}(*args).register
        end
      end
    }
  end  # method 'shape'

  require 'facets/string/titlecase'   # needed above

  #                                                                          #
  # ======================================================================== #
  #                                                                          #

    # A data object to contain the bits and pieces needed to deal with the
    # parameter specifications.  No processing is done here; it's just to
    # convey the data more easily.
  class ShapeCommandRawData
      # As provided to 'shape' command; e.g. :ABC or '3+' or nil.
    attr_reader :label
      # A hash of the declarations specified (if any); e.g.
      #   { "base" => "base: (segment,n=nil)" }
    attr_reader :declarations
      # The argument provided to 'fixed_parameter', if any.  e.g.
      #   :fixed_parameter => :type
    attr_reader :fixed_parameter
      # Hash mapping keywords to arrays of strings.  E.g.
      #   { :isosceles => [ "(base)", "(base), height: length", ... ],
      #     :right     => [ "right_angle: symbol", ...],
      #     :_         => [ "(base)", "(base), sides: [length,length,length]", ... ]
      #   }
      # If no keywords are used in the specification, then the default keyword
      # (:_) will be the only key in the hash.
    attr_reader :parameters

    def initialize(args={})
      @label_spec     = args[:label]
      @fixed_parameter = args[:fixed_parameter]
      @declarations   = _parse_declarations(args)
      @parameters     = _process_parameters(args)
    end

    def inspect
      %{
         | ShapeCommandRawData <
         |   label_spec     #{@label_spec.inspect}
         |   fixed_parameter #{@fixed_parameter.inspect}
         |   declarations   #{@declarations.inspect}
         |   parameters
      }.trim('|') +
        _pretty_print_parameters.indent(4) + "\n>"
    end

    def _parse_declarations(args)
      declarations_array = [ args[:declaration], args[:declarations] ].flatten.compact
      declarations_array.build_hash { |str|
        str.strip!
        key   = str.split(/:/).first
        value = str
        [key, value]       # e.g. [ "base", "base: (segment,n=nil)" ]
      }
    end
    private :_parse_declarations

    def _process_parameters(args)
      parameters_raw = args[:parameters] || Err.no_parameters_provided
      to_array = lambda { |str| str.strip.split(/\n/).map { |line| line.strip } }
      case parameters_raw
      when String
        # No keywords to worry about, just a big string of parameters.
        # We create a hash mapping from the default keyword to the parameters.
        { :_ => to_array[parameters_raw] }
      when Hash
        # A bunch of keywords, each mapping to a big string of parameters.
        returning(Hash.new) { |p|
          parameters_raw.each do |kwd, str|
            p[kwd] = to_array[str]
          end
        }
      end
    end
    private :_process_parameters

    def _pretty_print_parameters
      @parameters.map { |kwd, params|
        kwd.inspect + "\n" + params.join("\n").indent(2)
      }.join("\n")
    end
  end  # class ShapeCommandRawData

  #                                                                          #
  # ======================================================================== #
  #                                                                          #

  # ArgumentParser does the heavy lifting of processing the declarations and parameters
  # that are set in the 'shape' command.  This is how it is used:
  #   parser = ArgumentParser.new(raw_data)
  #   ...
  #   spec = parser.generate_construction_spec(label, fixed_arg, keyword_args)
  #
  # Internally, it uses the class DSL::ParameterSet to maintain knowledge of the
  # parameters that can be used, and to do the matching.
  class ArgumentParser
    def initialize(raw_data)
      @raw_data = raw_data
      @parameter_sets = returning(Hash.new) { |p|
        raw_data.parameters.each do |kwd, arr|
          p[kwd] = arr.map { |str|
            if str.strip == '-'
              ParameterSet.new([], "-")
            else
              ParameterSet.parse(str, raw_data.declarations)
            end
          }
        end
      }
    end
    def generate_construction_spec(label, fixed_arg, keyword_args)
      parameter_sets = @parameter_sets[fixed_arg || :_]
      Err.no_parameters_for_fixed_arg(fixed_arg) if parameter_sets.nil?
      parameter_sets.each do |pset|
        if spec = pset.generate_construction_spec(keyword_args)
          spec.label = label
          spec.fixed_parameter = @raw_data.fixed_parameter
          spec.fixed_argument = fixed_arg
          return spec
        end
      end
      # If we get this far, there's no match.
      Err.no_parameter_spec_matches_arguments(keyword_args, parameter_sets)
    rescue StandardError => e
      Err.problem_processing_arguments(keyword_args, e.message)
    end
  end  # class ArgumentParser
  # TODO: Consider whether ArgumentParser should be moved closer to
  #       RGeom::Shape.  It's not really about DSL anymore.
  # TODO: ArgumentParser turned out to be pretty small.  Could the code
  #       be rolled into ShapeProperties?

  #                                                                          #
  # ======================================================================== #
  #                                                                          #

  #
  # A ConstructionSpec object contains all the information needed for a method
  # like Circle.construct(spec) to do its job:
  # * Which set of specified parameters were used?
  #     spec.parameters             # [:centre, :radius]
  # * The value of those parameters.
  #     spec.radius                 # 7
  # * The label, if any.
  #     spec.label                  # Label[:C]
  # 
  # A complex shape like Triangle may use a "fixed parameter" to determine which
  # set of parameter specs apply.  For example,
  #
  #   shape :triangle, :label => :ABC, :fixed_parameter => :type,
  #     :parameters => {
  #       :isosceles => %{...},
  #       :equilateral => %{...},   # etc.
  #
  # We take care of that with the #fixed_parameter= method.
  #
  #   spec.fixed_parameter = :type  # Implementing the specification above.
  #   
  # Now if the user calls <tt>triangle(:ABC, :isosceles, ...)</tt>
  #
  #   spec.fixed_argument = :isosceles
  #   
  # and the construction code will see
  # 
  #   spec.type                     # :isosceles
  #
  # Finally, there's the curious *sans* method.  ("sans" is French for
  # "without".)
  #
  # An Arc specification is essentially a Circle specification with
  # the addition of angles (to give the start and stop points).  Therefore, a
  # sensible way to construct an Arc is to _remove_ the angles and construct a
  # Circle, then apply the angles.  To wit:
  #
  #   circle_spec = arc_spec.sans(:angles)
  #   circle = Circle.construct(circle_spec)
  #
  # #sans creates a copy of the specification but leaves out whatever
  # information you don't want.  It removes the angle _values_ and it removes
  # <tt>:angles</tt> from the parameter list.
  #
  #   circle_spec.angles            # nil
  #   circle_spec.parameters        # [:centre, :radius]
  #
  # == General use
  #
  # Initialise it with a hash, then manipulate values as needed.  Set the label
  # and parameters.
  #
  #   spec = ConstructionSpec.new :base => 10, :height => 3
  #   spec.height = 4
  #   spec.fixed_parameter = :type
  #   spec.fixed_argument  = :scalene
  #   spec.label           = :GIP
  #   spec.parameters      = [:base, :height]
  #
  # Notice the OpenStruct-like accessors.  You can add whatever attributes you
  # like.
  #
  class ConstructionSpec

    if RUBY_VERSION =~ /^1.8/
      undef :type   # Reserve this method name for our use.
    end
    attr_accessor :label, :parameters

    def initialize(hash)
      @values = hash
      @label  = nil
      @parameters      = []
      @fixed_parameter = nil
    end

    def fixed_parameter=(param)
      @fixed_parameter = param
    end

    def fixed_argument=(arg)
      if @fixed_parameter
        @values[@fixed_parameter] = arg
      end
    end

    def method_missing(symbol, *args, &block)
      case symbol.to_s
      when /^(\w+)$/
        @values[symbol]
      when /^(\w+)=$/
        @values[$1.intern] = args.first
      end
    end

    def indices(*args)
      @values.values_at(*args)
    end

    def sans(*args)
      values = @values.dup.delete_if { |k,v| k.in? args }
      ConstructionSpec.new(values).tap { |spec|
        spec.label      = @label
        spec.parameters = @parameters - args
        spec.fixed_parameter = @fixed_parameter
      }
    end

    def to_s
      values = @values.map { |k,v|
        sprintf("%s = %s", k.to_s.rjust(11), v.inspect)
      }.join("\n")
      return %{
        ConstructionSpec
          parameters: #{@parameters.inspect}
              label = #{@label.inspect}
      }.trim.tabto(0) + values
    end

  end  # class ConstructionSpec

  #                                                                          #
  # ======================================================================== #
  #                                                                          #

  # Should this go here or somewhere near RGeom::Shape?
  class ShapeProperties
    @@index = {}

    def ShapeProperties.[](shape_name)
      @@index[shape_name]
    end

    def initialize(shape_name, label_size, argument_parser)
      @shape_name = shape_name
      if @@index.key?(shape_name)
        Err.shape_already_exists_in_index
      end
      @label_validator =
        case label_size
        when Integer; lambda { |label| label.size == label_size }
        when String # like "3+"
          Err.not_implemented
        when nil;     lambda { |label| label.nil? }
        else
          Err.invalid_value_for_label_size
        end
      @argument_parser = argument_parser
      @@index[shape_name] = self
    end

    # Check to see whether the specified label (assumed to be a +Label+ object)
    # is valid according to the declarations in the DSL.
    #
    def label_valid_for_this_shape?(label)
      @label_validator.call(label)
    end

    # == ShapeProperties#generate_construction_spec
    #
    # A very important method: it ensures the arguments given to a command like
    # 'circle' are valid, and packages them up into a spec (OpenStruct) with
    # appropriate casting so that the <tt>Circle.construct</tt> method can do
    # its things fairly easily.
    #
    # +args+ may be something like:
    #
    #   [ :K, { :centre => :B, :radius => 7 } ]
    #
    # <tt>:K</tt> is a label and should be extracted, such that the return value
    # will be a spec like:
    #
    #   label  = :K
    #   centre = Point[4,1]         # note the casting from :B
    #   radius = 7
    #
    # The values returned in the spec are cast appropriately according to the
    # DSL declaration, so if :XY is provided and a 'length' is expected, then
    # the length of the segment XY will be the value returned.  This simplifies
    # construction logic immensely.
    #
    # A label is always returned, even if it's +nil+.
    #
    # If none of the declared parameter sets match the arguments given, it
    # returns +nil+ (I think).
    #
    def generate_construction_spec(args)
      # args will be like one of these:
      #   [ ]                                       -- nothing
      #   [ :K ]                                    -- just a label
      #   [ { :centre => :X, :radius => 7 } ]       -- hash in an array
      #   [ :K, { :centre => :X, :radius => 7 } ]   -- label followed by hash

      # We expect 'args' to be a label (symbol or string) followed by a hash.
      # Either of these may or may not exist.

      label, fixed_argument = nil

      # We look for keyword_arguments first.

      keyword_arguments = 
        if Hash === args.last
          args.pop
        else
          {}
        end

      # Now, do we have a label?  It's not compulsory, and there might be
      # another (fixed) argument, so we must proceed with caution.  If we can
      # extract one, we ensure it's valid before continuing.

      unless args.empty?
        label = _extract_label(args) #Label[args.shift]
        unless label.nil? or label_valid_for_this_shape?(label)
          Err.invalid_label_specified(@shape_name, label)
        end
      end

      # After a label, there may be a fixed argument.  It will be the only thing
      # left in the argument list.

      unless args.empty?
        fixed_argument = args.shift
      end

      # Having extracted the label and the hash (and removed them from 'args'), there
      # should be nothing left.  If there is, it's an error.

      unless args.empty?
        Err.too_many_arguments_provided(args)
      end

      # Finally, we take our keyword arguments and try them against each
      # parameter specification to see if they match.  First match wins, and we
      # return the 'spec' (ConstructionSpec) that is generated.

      @argument_parser.generate_construction_spec(
              label, fixed_argument, keyword_arguments)
    end

      # Looks for, removes, and returns a label from the given array.
      # We do _not_ check to see that the label is valid for this shape; that's
      # the responsibility of the caller of this method.
    def _extract_label(args)
      index = catch(:found) {
        args.each_with_index do |arg, idx|
          if l = Label[arg]
            throw :found, idx
          end
        end
        nil
      }
      if index
        result = Label[args.delete_at(index)]
      end
    end
    private :_extract_label

  end  # class ShapeProperties

end; end  # module DSL; module RGeom

