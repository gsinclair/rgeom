
module RGeom::Support
  class Label
    def initialize(symbol)
      @symbol = symbol
      @string = symbol.to_s
      @array  = @string.split(//).map { |c| c.intern }
      @size   = string.size
      self.freeze
    end
    def Label.[](symbol)
      Label.new(symbol)
    end
    attr_reader :symbol, :string, :array, :size
  end
end
