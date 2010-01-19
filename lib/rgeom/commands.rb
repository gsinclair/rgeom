
module RGeom
  
  module Commands

    def pt(*args)
      Point[*args]
    end
    alias p pt

      # Examples:
      #   seg p(1,1), p(-5,8)
      #   seg _segment(:AB)
      #   seg :AB
      #   seg nil      # -> nil
    def seg(*args)
      args = args.flatten
      case args.map { |x| x.class }
      when [Segment]
        args.first
      when [Symbol]
        Segment.from_symbol(args.first)
      when [Point, Point]
        Segment.simple(*args)
      when [NilClass]
        nil
      else
        nil
      end
    end
    alias s seg

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

    def generate(*args, &block)
      Shape.generate(*args, &block)
    end

    def render(filename, *args)
      Diagram.new(filename).render(*args)
    end

  end
end

__END__

### These commands are now generated automatically (or they will be when
### the DSL is complete).  Delete them when the time comes.

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

  end  # module Commands

end  # module RGeom
