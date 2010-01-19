
module RGeom

  module Support

    class ArgumentProcessor; end
    class Specification; end    # NOTE: Unneeded after DSL is running.
    class Label; end

    class ::Integer
        # 35.d means 35 degrees; it's just decoration.
      def d; self; end
    end

    module ::Kernel
      undef :p   # We use p for creating a point.
    end

    class ::Float
      def Float.close?(a, b, tolerance=0.000001)
        (a - b).abs < tolerance
      end
    end

    class ::Object
      def blank?
        self.nil? or ((self.respond_to? :empty?) and self.empty?)
      end
      def safe_send(message)
        if self.respond_to? message
          self.send message
        else
          nil
        end
      end
      def returning(obj)
        x = obj
        yield x
        return x
      end
    end
    
    class ::OpenStruct
      undef :type  # We need to use 'type' as an attribute; this clashes.
    end

    class ::Numeric
      D2R_MUlTIPLIER = Math::PI / 180.0
      R2D_MULTIPLIER = 180.0 / Math::PI
      def in_radians; self * D2R_MUlTIPLIER; end
      def in_degrees; self * R2D_MULTIPLIER; end
    end

    class ::Array
        # [1,2,3].return_value    == [1,2,3]
        # [5].return_value        == 5
      def return_value
        (self.size == 1) ? self.first : self
      end
    end

    class ::Symbol   # TODO this stuff will be replaced by Label
        # :ABC -> [:A, :B, :C]
      def split; self.to_s.split(//).map { |c| c.to_sym }; end
      def length; to_s.length; end
    end

    class Util       # TODO so will this
        # :XMP => "MPX"
      def Util.sort_symbol(sym)
        sym.to_s.split(//).sort.join
      end
    end

  end  # module Support
end  # module RGeom

