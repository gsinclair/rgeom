
# Maybe the classes defined below will end up in RGeom::DSL rather than just
# RGeom.

module RGeom; module DSL;

  # Examples of use:
  #
  #   number = Type.new( :number, [ lambda { |o| o.numeric? and o } ] )
  #
  #   Type.add_type :type => number, :aliases => [:n, :angle]
  #
  #   Type[:number]              # -> Type
  #   Type[:n]                   # -> Type::Alias
  #   Type[:angle]               # -> Type::Alias
  #
  #   Type[:angle].match(65)     # -> 65
  #   Type[:number].match(:foo)  # nil
  #
  # Notes on Type::Compound and Type::Array to follow.  They have the same
  # interface: <tt>match(object)</tt>.
  # 
  class Type
    @@index = Hash.new
    NO_DEFAULT = Parameter::NO_DEFAULT

    def Type.add_type(args={})
      type    = args[:type]    || (raise "Type.add_type requires argument :type")
      aliases = args[:aliases] || []
      label   = type.label
      _check_not_already_defined(label)
      @@index[label.to_s] = type
      aliases.each do |label|
        _check_not_already_defined(label)
        @@index[label.to_s] = Type::Alias.new(label, type)
      end
    end

    def Type.index
      @@index
    end

    def Type._check_not_already_defined(label)
      if @@index.key? label
        raise ArgumentError, "Datatype #{label.inspect} has already been defined"
      end
    end

    def Type.[](label)
      @@index[label.to_s]
    end

    attr_reader :label

    def initialize(label, matchers)
      @label, @matchers = label, matchers
    end

    def match(object)
      @matchers.each do |m|
        result = m.call(object)
        return result if result
      end
      nil
    end

    def to_s; @label.to_s end
    def inspect; "Type<#{@label.inspect}>" end

    class Alias
      def initialize(label, type)
        @label, @type = label, type
      end

      def match(object)
        @type.match(object)
      end

      def to_s; @label.to_s end
      def inspect; "Type<#{@label.inspect}>" end
    end

    class Compound
      def initialize(label, types)
        @label, @types = label, types
      end

      def match(object)
        @types.each do |type|
          result = type.match(object)
          return result unless result.nil?
        end
        nil
      end

      def to_s; @label.to_s end
      def inspect; "Type<#{@label.inspect}>" end
    end

    class Array
      def initialize(label, types)
        @label, @types = label, types
      end

      def match(object)
        input = object
        if ::Array === input and input.size == @types.size
          match =
            (0...@types.size).map { |i|
              @types[i].match( input[i] )
            }
          if match.any? { |x| x.nil? }
            return nil
          else
            return match
          end
        else
          nil
        end
      end

      def to_s; @label.to_s end
      def inspect; @label.inspect end
    end

  end  # class Type

  # Example code for +datatype+ method:
  #
  #   (1) datatype :length,
  #         :match => [
  #           lambda { |o| o.numeric? and o },
  #           lambda { |o| o.symbol? and o.length == 2 and Segment[o].length },
  #           lambda { |o| o.is_a? Segment and o.length }
  #         ]
  #    
  #   (2) datatype :number, :alias => [:n,:angle],
  #         :match => lambda { |o| o.numeric? and o }
  #    
  #   (3) datatype :point { |o| o.is_a? Point and o }
  #    
  #   (4) datatype :point, :is_a? Point
  #         # Shorthand for (3).
  #
  # Data types can be specified in a variety of ways. (1) is straightforward;
  # (2) involves aliases; (3) uses an inline block instead of +match+; (4) uses
  # shorthand and will lead to code generation.
  #
  # The various keyword arguments, then, are:
  #
  # match:: Either a lambda or an array of lambdas.  The lambda simultaneously
  #         determines whether a given object matches this datatype, and returns
  #         the object (which may be cast, say from <tt>:AB</tt> to
  #         <tt>Segment[:AB]</tt>.
  #
  # alias:: Alternative name(s) for the datatype.  Symbol or array of symbols.
  #
  # is_a::  Class, instances of which will successfully match this datatype.
  #         Leads to generated code, so it's a shorthand.  See examples 3 and 4
  #         above.
  #
  # An inline block is equivalent to a +match+ argument with a single lambda.
  # If a +match+ and an inline block are both provided, an error is raised.
  def datatype(name, args={}, &block)
    matchers = []
    aliases  = []

    if block_given?
      matchers << block
      if args.key? :match
        raise ArgumentError, "datatype: explicit 'match' and implicit block both given"
      end
    elsif args.key? :match
      matchers << args[:match]
    end

    if args.key? :alias
      aliases << args[:alias]
    end

    if args.key? :is_a
      unless matchers.empty?
        raise ArgumentError,
          "datatype: 'is_a' can't be used in concert with other matchers"
      end
      klass = args[:is_a]
      unless klass.is_a? Class
        raise ArgumentError, "datatype: 'is_a' argument must be a class"
      end
      matchers = [ lambda { |o| o.is_a? klass and o } ]
    end

    matchers = matchers.flatten
    aliases  = aliases.flatten

    type = Type.new(name, matchers)
    Type.add_type :type => type, :aliases => aliases

  end  # DSL method 'datatype'


  class ::Object
    def string?;  is_a? String  end
    def range?;   is_a? Range   end
    def numeric?; is_a? Numeric end
    def integer?; is_a? Integer end
    def symbol?;  is_a? Symbol  end
  end  # class ::Object


  #
  # Parser provides some methods for extracting values out of a string.
  #
  # E.g.
  #
  #   Parser.ordered_pairs '(4,7) (-3.1, 0.7)'   # -> [ [4,7], [-3.1,0.7] ]
  #   Parser.range         '15,20,...,37'        # -> [15,20,25,30,35]
  #
  # These assist in datatype specifications, for instance:
  #
  #   datatype :range,
  #     :match => [
  #       lambda { |o| o.range? and o.to_a },
  #       lambda { |o| o.string? and Parser.range(o) }
  #     ]
  #
  class Parser

      # "30,40...82" -> [30,40,50,60,70,80]
    def Parser.range(str)
      str = str.delete(" ")
      if str =~ / (-?\d+) , (-?\d+) ,? \.\.\. ,? (-?\d+) /x
        first, second, last = $1.to_i, $2.to_i, $3.to_i
        difference = second - first
        nterms = (last - first) / difference + 1
        if nterms < 0 then nterms = 0 end
        (0...nterms).map { |n| first + n * difference }
      end
    end

    def Parser.ordered_pairs(str)
      str = str.delete(" ")
      result = []
      if str =~ %r{ \A (  \( [-0-9.,]+ \) ,?  )+ \Z }x
        # We probably have a match; we need to look at the contents of the
        # brackets.
        str.scan(/\( (.*?) \)/x) do |match|
          # 'match' should look something like '-2.56,1'.  If we split on the
          # comma and successfully convert both bits to a number, we're done.
          x, y, _ = match.split(/,/)
          return nil unless _.nil?
          x, y =
            begin
              [ ( Integer(x) rescue Float(x) ),
                ( Integer(y) rescue Float(y) ) ]
            rescue ArgumentError
              # Can't turn the string into a number; this set of ordered pairs
              # is bogus.
              return nil
            end
          result << [x, y]
        end
      end
      return result
    end
  end  # class Parser


  #
  # value "origin",   :value => Point[0,0]
  # value "nil",      :value => nil
  # value /[0-9].-/,  :value => lambda { |x| Integer(x) rescue Float(x) }
  #
  class Value
    @@values = {}

    def Value.add_value(name, value)
      if @@values.key?(name)
        Err.value_already_defined(name, @@values[name], value)
      else
        @@values[name] = value
      end
    end

    def Value.[](str)
      if @@values.key?(str)
        return @@values[str]   # this takes care of 'origin' and 'nil'
      else
        # value /[0-9].-/,  :value => lambda { |x| Integer(x) rescue Float(x) }
        @@values.each do |key, value|
          if Regexp === key and key.match(str)
            if Proc === value
              return value.call(str)
            else
              return value
            end
          end
        end
      end
    end
  end  # class Value

  def value(name, args={})
    unless args.key? :value
      Err.no_value_specified
        # We do it this way because it could (legitimately) be :value => nil
    end
    value = args[:value]
    Value.add_value(name, value)
  end

end; end  # module DSL; module RGeom
