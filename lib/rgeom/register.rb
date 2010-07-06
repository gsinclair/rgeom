
require 'facets/dictionary'

module RGeom
  class Style
    def Style.blank
      Style.new
    end
  end
end

module RGeom
  class Row
    ID_PREFIXES = {
      :triangle => 'tri', :segment => 'seg', :circle => 'cir',
      :square => 'squ', :arc => 'arc',
    }
    ID_NUMBER = {
      :triangle => 0, :segment => 0, :circle => 0, :square => 0, :arc => 0,
    }
    fattr :category, :id, :shape, :style
    def initialize(category, shape)
      @category = category
      @shape = shape
      @id = next_id_for_category(category)
      shape.id = id
    end
    def next_id_for_category(category)
      prefix = ID_PREFIXES[category]
      number = (ID_NUMBER[category] += 1)
      string = prefix + (sprintf "%02d", number)
      string.to_sym
    end
    def Row.reset_counts!
      ID_NUMBER.each_key do |cat|
        ID_NUMBER[cat] = 0
      end
    end
    def to_s
      guts = [@category.inspect, @id.inspect, @shape.to_s(:short)].join(", ")
      "[" + guts + "]"
    end
    def inspect
      "Row" + to_s
    end
  end  # class Row
end  # module RGeom





module RGeom

  class Register

    include Singleton
    include Enumerable

    def initialize
      init
    end

    def init
      @points = Dictionary.new
      @rows = Array.new
      @by_id = Hash.new
      @by_category = Hash.new { |h,k| h[k] = [] }
      @by_label = Hash.new
      Row.reset_counts!
      #debug "Register initialised"
    end
    private :init

    def clear!
      init
    end

    def npoints; @points.size; end
    def nobjects; @rows.size; end

    def [](point_name)
      @points[point_name]
    end

    def []=(point_name, point)
      raise ArgumentError, "Expect (Symbol, Point)" unless Point === point
      if point_name == :_ or point_name == nil
        return nil
      end
      if @points.key? point_name
        if (existing = @points[point_name]) != point
          Err.redefine_point(point_name, existing, point)
        else
          #STDERR.puts "Intercepted attempt to reassign Point #{point_name}"
          return point
        end
      end
      @points[point_name] = point
      # debug "register[#{point_name}] = #{point}"
    end

    def store_points(names, points)
      names.zip(points) do |n,p|
        self[n] = p
      end
    end

    def retrieve_points(names)
      names.map { |n| self[n] }
    end

      # Given Triangle t with vertices :A, :B and :C
      #   store(:triangle, t)
      #   retrieve(:triangle, :ABC) -> t
      #   retrieve(:triangle, :CAB) -> t
      #   retrieve(:triangle, t)    -> t
      #   retrieve(:triangle, :XYZ) -> nil
      #
      # TODO: reinstate the check for repeated storing of same object (?)
    def store(category, shape)
      row = Row.new(category, shape)
      @rows << row
      @by_id[shape.id] = shape
      @by_category[category] << shape
      if shape.label
        key = "#{category}_#{RGeom::Util.sort_symbol(shape.label)}"
        @by_label[key] = shape
      end
    end

      # Removes the given shape from the register.
      # TODO: This is awkward; the register wasn't designed to have things
      # removed.  Perhaps there is a way to avoid unwanted shapes going into the
      # register in the first place.
    def remove(category, shape)
      @rows.delete_if { |row| row.id == shape.id }
      @by_id.delete_if { |id, row| id == shape.id }
      @by_category[category].delete_if { |sh| sh.id == shape.id }
      if shape.label
        key = "#{category}_#{RGeom::Util.sort_symbol(shape.label)}"
        @by_label.delete_if { |k,v| k == key }
      end
    end

    def by_label(category, label)
      return nil if label.nil?
      key = "#{category}_#{RGeom::Util.sort_symbol(label)}"
      debug key
      debug @by_label.pretty_inspect
      @by_label[key]
    end

    def by_id(id)
      @by_id[id]
    end

    def by_category(category)
      @by_category[category]
    end

    def nth(category, n)
      @by_category[category].at(n)
    end

    def each
      @rows.each do |row|
        yield row
      end
    end
    alias each_row each

    def each_object
      @rows.each do |row|
        yield row.shape
      end
    end

      # Returns a string like "TFF" to report on whether a number of points are
      # defined.  A regular expression can then be used to interpret the string.
#   def mask(point_names)
#     point_names.map { |n| (@points.key? n) ? :T : :F }.to_s
#   end

    def to_s
      "Register:".green.bold + "\n" +
        "  Points:\n" +
        @points.map { |k,v| "#{k}#{v}" }.join("\n").indent(4) + "\n" +
        "  Rows:\n" +
        @rows.map { |row| row.inspect }.join("\n").indent(4)
    end

  end  # class Register

end  # module RGeom
