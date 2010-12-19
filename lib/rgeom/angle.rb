
module RGeom
  # Represents an angle.
  #
  #   a = 31.d    # -> Angle[31 degrees]
  #   a.deg       # -> 31
  #   a.rad       # -> 0.54105...
  #
  #   b = 1.06.r  # -> Angle[1.06 radians]
  #   b.deg       # -> 60.7335...
  #   b.rad       # -> 1.06
  #
  #   a + b       # -> Angle[91.73... degrees]
  #   a * 1.5     # -> Angle[46.5 degrees]
  #
  #   c = 45.d
  #   c.sin       # -> 0.7071...
  #   c.cos       # -> 0.7071...
  #   c.tan       # -> 1.0000...
  #
  class Angle
    def initialize(value, unit)
      x = sprintf "%3.3f", value
      case unit
      when :degrees
        @deg = value
        @rad = value * Math::PI / 180
        @str = "Angle[#{x}d]"
      when :radians
        @deg = value * 180 / Math::PI
        @rad = value
        @str = "Angle[#{x}r]"
      else
        raise "Wrong unit -- use :degrees or :radians"
      end
      self.freeze
    end

    attr_reader :deg, :rad

    def +(other)
      value = self.deg + other.deg
      Angle.new(value, :degrees)
    end

    def -(other)
      value = self.deg - other.deg
      Angle.new(value, :degrees)
    end

    def *(n)
      value = self.deg * n
      Angle.new(value, :degrees)
    end

    def <=>(other)
      return false if other.nil?
      raise ArgumentError, "Can only compare Angle with Angle" unless Angle === other
      self.deg.to_f <=> other.deg.to_f
    end
    include Comparable

    def ==(other)
      return false if other.nil?
      raise ArgumentError, "Can only compare Angle with Angle" unless Angle === other
      diff = (self.deg.to_f - other.deg).abs
      diff.zero? or (diff / other.deg) <= 0.00001
    end

    def sin; Math.sin(self.rad) end
    def cos; Math.cos(self.rad) end
    def tan; Math.tan(self.rad) end

    def to_s; @str; end
    alias inspect to_s

  end  # class Angle

  class ::Numeric
    def d
      Angle.new(self, :degrees)
    end
    def r
      Angle.new(self, :radians)
    end
  end

end  # module RGeom
