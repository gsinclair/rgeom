
module RGeom

  module Support

    # TODO: Implement debuglog gem!
    module ::Kernel
      def debug(msg)
        :no_op
      end
    end

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
      def not_nil?
        not nil?
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
      def in?(collection)
        collection.include?(self)
      end
    end
    
    class ::OpenStruct
      if RUBY_VERSION =~ /^1.8/
        undef :type  # We need to use 'type' as an attribute; this clashes.
      else
        # doesn't matter -- Object#type isn't defined in 1.9
      end
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

    module ::Enumerable
      # numbers  = (1..3)
      # squares  = numbers.build_hash { |n| [n, n*n] }   # 1=>1, 2=>4, 3=>9
      # sq_roots = numbers.build_hash { |n| [n*n, n] }   # 1=>1, 4=>2, 9=>3
      def build_hash
        result = {}
        self.each do |elt|
          key, value = yield elt
          result[key] = value
        end
        result
      end
      alias includes? include?
      alias contains? include?
    end

    class ::String
      # See http://extensions.rubyforge.org/rdoc/classes/String.html#M000033
      def trim(margin=nil)
        s = self.dup
        # Remove initial blank line.
        s.sub!(/\A[ \t]*\n/, "")
        # Get rid of the margin, if it's specified.
        unless margin.nil?
          margin_re = Regexp.escape(margin || "")
          margin_re = /^[ \t]*#{margin_re} ?/
            s.gsub!(margin_re, "")
        end
        # Remove trailing whitespace on each line
        s.gsub!(/[ \t]+$/, "")
        s
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

