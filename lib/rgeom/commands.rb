
module RGeom
  
  module Commands

    def p(*args)
      Point[*args]
    end


      # points :A => [4,1], :B => [5,-3], :C => p(3,0)
    def points(pts={})
      @register ||= RGeom::Register.instance
      pts.each_pair do |name,coords|
        @register[name] = Point[coords]
      end
      nil
    end



      # midpoint(:AC)
    def midpoint(labels)
      segment(labels).midpoint
    end


    def _segment(*args) Segment.create(*args) end
    def _circle(*args)  Circle.create(*args)  end
    def _arc(*args)     Arc.create(*args)     end
    def _square(*args)  Square.create(*args)  end

    def segment(*args)    _segment(*args).register    end
    def circle(*args)     _circle(*args).register     end
    def triangle(*args)   _triangle(*args).register   end
    def arc(*args)        _arc(*args).register        end
    def semicircle(*args) _semicircle(*args).register end
    def square(*args)     _square(*args).register     end

    def _triangle(*args)
      # TODO the code below is necessary but ugly.  Find a way to include it
      # somewhere else.  In fact, all of these funtions triangle(), segment,
      # circle() etc. have the same pattern.  It can probably be moved to Shape.
      # Maybe Shape.create(:triangle, *args) or something.
      if args.first.to_s =~ /^([A-Z]{3})$/
        label = $1
        @register ||= RGeom::Register.instance
        if t = @register.by_label(:triangle, label)
          # The user has called triange(:ABC, ...) for the second time, so
          # we return the existing triangle.
          if args.size > 1
            warn "triangle: Found existing triangle with vertices #{label}; ignoring extra arguments."
          end
          return t
        end
      end
      Triangle.create(*args)
    end

    def _semicircle(*args)
      if Hash === args.last
        args.last[:angles] = [0,180]
      else
        args << Hash[:angles => [0,180]]
      end
      Arc.create(*args)
    end

    # Consider this method:
    #
    #   def triangle(*args)
    #     _triangle(*args).register
    #   end
    #
    # That is, <tt>_triangle</tt> creates a triangle but doesn't register it.
    # <tt>triangle()</tt> creates a triangle and registers it.  That's an easy
    # way for the user to choose whether a shape will be drawn or not.  (They
    # may want to "create" a shape just for the purpose of constructing another
    # one.)
    #
    # This block generates such methods for triangle, segment, etc.
    #

#   [:triangle, :segment, :circle, :arc, :square, :semicircle].each do |method|
#     underscore_method = "_#{method}"
#     define_method(method) { |*args|
#       send(underscore_method, *args).register
#     }
#   end




=begin (some circle docs to use somewhere sometime)
      # Some examples:
      #   circle(:H, :centre => :P, :radius => 5)
      #   circle(:H, :centre => :P, :diameter => 10)
      #   circle(:H, :centre => :P, :radius => :AB)    where :AB is an existing segment
      #   circle(:H, :centre => :P, :diameter => :MP)
      #   circle(:K, :radius => :AB)                   implies centre = :A
      #   circle(    :diameter => :MN)                 implies centre = midpoint :AB
      #   circle(:L, :centre => p(2,6), :radius => 14)
      #   circle(:L, :centre => p(2,6), :diameter => 28)
      #   circle(    :diameter => :MN, :centre => p(3,0))
      # 
      # * Label is optional and cannot be derived from the other information.
      # * A centre can be a Point or a Symbol.
      # * A radius can be a number or a Symbol, and the symbol can mean the phyical
      #   radius or a segment indicating its length.
      # * The diameter is like the radius in this respect.
      # * Anytime a two-letter symbol is given, it must resolve.  You can't create
      #   points implicitly through a circle; it doesn't make much sense.
=end


    def generate(*args, &block)
      Shape.generate(*args, &block)
    end



    def render(filename, *args)
      Diagram.new(filename).render(*args)
    end

  end  # module Commands

end  # module RGeom
