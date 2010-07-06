
module RGeom
  #
  # The purpose of the Label class is to make it easy to access the size of the
  # label and its constituent symbols.  E.g.
  #
  #   l = Label[:AFR]
  #   l.symbol            # :AFR
  #   l.symbols           # [:A, :F, :R]
  #   l.string            # "AFR"
  #   l.size              # 3
  #   l == :AFR           # true
  #   l == Label[:AFR]    # true
  #
  # In the future it may be worth adding "smart" functionality to labels, such
  # as:
  #
  #   l.type              # :triangle
  #   l.points            # [Point[4,1], Point[3,8], nil]
  #
  # It might allow me to remove VertexList and simplify client code.
  #
  class Label
    def initialize(symbol)
      @symbol = symbol
      if @symbol
        @string  = symbol.to_s
        @symbols = @string.split(//).map { |c| c.intern }
        @size    = string.size
      else
        @string  = "nil"
        @symbols = []
        @size    = 0
      end
      self.freeze
    end
    def Label.[](symbol)
      (symbol.nil?) ? nil : Label.new(symbol)
    end
    def to_s; @string; end
    def inspect; "Label[#{@symbol.inspect}]"; end
    def nil?; @symbol.nil? end   # Dodgy?
    attr_reader :symbol, :string, :symbols, :size

    def ==(obj)
      case obj
      when Symbol
        @symbol == obj
      when Label
        @symbol == obj.symbol
      else
        false
      end
    end

    # TODO Consider adding pointlist functionality to Label.

  end  # class Label
end  # module RGeom
