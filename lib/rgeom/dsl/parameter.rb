
module RGeom; module DSL

  #
  # Consider this snippet of DSL code:
  #
  #   shape :circle, :label => :K,
  #     :parameters => %{
  #       centre: point=origin, radius: length=1           # (1)
  #       centre: point=origin, diameter: length           # (2)
  #       radius: segment                                  # (3)
  #       diameter: segment                                # (4)
  #     }
  #
  # There are four parameter sets specified here (see ParameterSet).  A closer
  # look at the second one reveals two parameters:
  #
  #       centre: point=origin, diameter: length           # (2)
  #
  # Two Parameter objects will arise from this:
  #
  #   Parameter:                    Parameter:
  #     name: :centre                 name: :diameter
  #     type: Type<point>             type: Type<length>
  #     constraint: nil               contraint: nil
  #     default: Point[0,0]           default: NO_DEFAULT
  #
  class Parameter
    NO_DEFAULT    = Object.new
    def NO_DEFAULT.to_s
      "-"
    end

    attr_reader :name, :type, :constraint, :default
    def initialize(name, type, args={})
      @name, @type = name, type
      @constraint = args[:constraint]
      @default    = args[:default]
    end

      # Does the given object match this parameter?
      # That is, can it be cast to the required type?
      # The Type class has the answer.
    def match(object)
      @type.match(object)
    end

    def default?
      NO_DEFAULT != @default
    end

    def constraint?
      @constraint.not_nil?
    end

    def inspect
      if default?
        "Parameter: #{name} (#{type}) [#{default.inspect}]"
      else
        "Parameter: #{name} (#{type})"
      end
    end
  end  # class Parameter

  #
  # ParameterSet represents, obviously enough, a set of parameters.  Consider
  # this DSL code:
  #
  #   shape :circle, :label => :K,
  #     :arguments => %{
  #       centre: point=origin, radius: length=1           # (1)
  #       centre: point=origin, diameter: length           # (2)
  #       radius: segment                                  # (3)
  #       diameter: segment                                # (4)
  #     }
  #
  # Lines 1-4 each represent a parameter set, and will be turned into a
  # ParameterSet object.
  #
  # The essential question you ask of a parameter set is "Does this set of
  # arguments match this set of parameters?"  That is the business of the
  # +match+ method.  It would be nice to call it <tt>match?</tt>, but it doesn't
  # just answer yes or no; it actually returns the appropriate set of values,
  # which can include default values and values modified by casting.  For
  # example:
  #
  #   IN:    :centre => :B
  #   OUT:   :centre => Point[4,1], :radius => 1
  #
  # +centre+ was cast to a Point object and +radius+ took on the default value
  # specified in Line 1 above.
  #
  class ParameterSet
    attr_reader :parameters

    def initialize(parameters, string)
      @parameters   = parameters.freeze
      @names        = parameters.map { |p| p.name }.freeze
      @string       = string.freeze
    end

    def inspect(format=:short)
      case format
      when :short
        "ParameterSet[#{@names.join(', ')}]"
      when :long
        "ParameterSet\n" + @parameters.map { |p| p.inspect }.join("\n").indent(2)
      else
        "ParameterSet[invalid format]"
      end
    end

    def to_s
      @string
    end

    #
    # A string can represent all of the information represented by the
    # ParameterSet class.  This method's job is to parse that string to extract
    # the information.
    #
    #   ParameterSet.parse "centre: point=origin, diameter: radius"
    #     # -> ParameterSet[centre, diameter]
    #
    # Forward declarations can be made to tidy up the parameter specifications.
    # For example (excerpt from a 'shape' command):
    #     :declaration => "base: (segment,n=nil)",
    #     :parameters => %{
    #         (base)
    #         (base), height: length
    #         (base), angle: n
    #     }
    #
    # We replace any use of declarations with their full expansion before parsing.
    def ParameterSet.parse(string, declarations={})
      # declarations is a hash like
      #   { "base" => "base: (segment,n=nil)", "foo" => "foo: angle=90" }
      # We search for "(base)" and "(foo)" and replace them with the appropriate
      # text.
      declarations.each do |search, replace|
        search = "(#{search})"
        string.gsub! search, replace
      end
      ParameterSet::Parser.new(string).result
        # Returns a ParameterSet object
    end

    # == ParameterSet#generate_construction_spec
    #
    # One of the most important methods in the RGeom DSL arsenal.  We see
    # whether a given set of keyword arguments satisfies this particular
    # parameter set.  In doing so, we create a ConstructionSpec object that
    # Shape.create can use to create the shape the user wants.
    #
    # For example, assuming the parameter combination is represented by
    #
    #   base: (segment,n=nil), angles: [n,n]
    #
    # and we call
    #
    #   generate_construction_spec(:base => :AB, :angles => [45,30])
    #
    # then the arguments match, and we return a ConstructionSpec that looks like
    # this:
    #
    #   base       = Segment(...)
    #   angles     = [45,30]
    #   parameters = [:base, :angles]
    #
    # The calling code will add the label information, if any.  The 'parameters'
    # information may be important in constructing the shape.
    #
    # As an enhancement, perhaps this spec could contain the actual ParameterSet
    # object, or a string representation, for error-reporting or whatever.  (May
    # not actually be needed.)
    #
    # Outline of operation:
    # * Each parameter in this parameter set is examined.
    # * Do any of the keyword arguments given have the same name as this parameter?
    # * If so, can the provided value be cast to the required type?
    # * If not, does this parameter have a default value?
    # * As we go, build up a results hash for conversion into a ConstructionSpec
    #   object.
    # * When all parameters have been checked, we see if there are any excess
    #   arguments.  If there are, it's not a valid match.
    #
    # Return value: a ConstructionSpec object (without the label or fixed
    # argument filled in; we don't know those values), or +nil+ if the given
    # keyword arguments do not match this parameter set.
    #
    def generate_construction_spec(args={})
      error = catch(:fail) do
        # Go through each formal parameter.  Is there a corresponding argument?
        # If not, is there a default value?  As we go, we build up a hash of
        # values we will ultimately use.
        result = {}
        @parameters.each { |p|
          name = p.name
          if args.key?(name)
            result[name] = _process(p, args, name)   # May throw :fail
          elsif p.default?
            result[name] = p.default
          else
            # We have a parameter for which there is no default value, and no
            # value was specified.  Therefore, the given arguments DO NOT match
            # this parameter set.
            throw :fail, [name, nil]
          end
        }
        # Now we check there were no _excess_ arguments, and build the return
        # value.
        _check_for_excess_arguments(args)    # May throw :fail
        begin
          debug "ParameterSet#match succeeded."
          debug "  * args   = #{args.inspect}"
          debug "  * params = #{@parameters.inspect}"
          debug "  * result = #{result.inspect}"
        end if $debug_parameters
        return ConstructionSpec.new(result).tap { |spec|
          spec.parameters = @names.dup
        }
      end
      if error
        # We could print some message here, like
        #   debug "Argument #{error[1]} failed to match parameter #{error[0]}."
        # However, there's not much point.  It's an intentional part of the
        # workflow that parameters won't match, not an error.
        return nil
      end
    end  # ParameterSet#match(args)

    # Specialist method to see if a given argument "matches" the parameter.
    # Throws <tt>:fail</tt> if it doesn't; returns the cast argument if it does.
    def _process(parameter, args, name)
      p = parameter
      value1 = args[name]           # The uncast value, e.g. :AB for a segment.
      if value2 = p.match(value1)   # See if it can be cast (e.g. to Segment[:AB]).
        return value2               # If so, we return the cast value.
      else
        throw :fail, [name, value1]
      end
    end
    private :_process

    def _check_for_excess_arguments(args)
      excess_arguments = args.keys - @names
      unless excess_arguments.empty?
        arg = excess_arguments.first; val = args[arg]
        throw :fail, [arg, val]
      end
    end
    private :_check_for_excess_arguments

  end  # class ParameterSet

  class ParameterSet
    #
    # Here we implement the parsing of parameter strings, using a Treetop
    # grammar to get us started, and maybe some help from Type::Array.parse etc.
    #
    # The examples in the comments assume the following input string:
    #
    #    "label, centre: point=origin, diameter: (segment,n=5), angle: [n,n]"
    #
    class Parser
      require 'treetop'
      require 'rgeom/dsl/grammar/parameters'
      class ::Treetop::Runtime::SyntaxNode
        def t; text_value; end

          # e.g. x[0,1,0] == x.elements[0].elements[1].elements[0]
        def [](*args)
          args.inject(self) { |node, n| node.elements[n] }
        rescue NoMethodError
          return nil     # Burrowed too deep
        end

          # Return a pretty string representation with some of the detail removed.
        def pretty
          regex = /"[A-z]?"$/
          self.pp_s.lines.reject { |l| l =~ regex }.join
        end

        def subtext
          elements.map { |x| x.text_value }
        end
      end

      @@parser = ParametersParser.new

      def initialize(string)
        @string = string
      end

      # Returns a ParameterSet object.
      def result
        details = self.parameter_details
          # -> array of OpenStruct with fields 'name' and 'type'
          # The 'name' is a string ("radius") that needs to be interned (:radius).
          # The 'type' is only a string, like "(segment,n=5)", that needs to be parsed.
        params = details.map { |o|
          type_info    = Type.parse(o.type)
          p_name       = o.name.intern
          p_type       = type_info.type
          p_default    = type_info.default
          p_constraint = type_info.constraint
          Parameter.new(p_name, p_type,
                          :default => p_default, :constraint => p_constraint)
        }
        ParameterSet.new(params, @string)
      end

      # Returns an array of OpenStructs with strings :str and :name and :type.
      # Given the example input string, the result would be:
      # 
      #   [ OpenStruct[ name: "label",    type: nil             ],
      #     OpenStruct[ name: "centre",   type: "point=origin"  ],
      #     OpenStruct[ name: "diameter", type: "(segment,n=5)" ],
      #     OpenStruct[ name: "angle",    type: "[n,n]"         ]   ]
      #
      # This is helpful in creating the Parameter objects and sorting out the
      # type strings that need to be parsed.
      def parameter_details
        parameter_strings.map { |str|
          p = @@parser.parse(str)
          name = p.parameter.parameter_name.text_value
          type = p[0,1,1].text_value rescue nil
          OpenStruct.new(:str => str, :name => name, :type => type)
        }
      end

      # Assuming the input string above, returns:
      #
      #   ["label", "centre: point=origin", "diameter: (segment,n=5)", "angle: [n,n]"]
      #
      def parameter_strings
        # element[0].t         - first parameter
        # element[1,0,1].t     - second parameter
        # element[1,1,1].t     - third parameter
        # element[1,2,1].t     - fourth parameter
        p = @@parser.parse(@string)
        first = p.elements[0]
        rest = p.elements[1].elements.map { |e| e.elements[1] }
        ([first] + rest).map { |e| e.text_value }
      end

    end  # class Parser
  end  # class ParameterSet

end; end  # module DSL; module RGeom
