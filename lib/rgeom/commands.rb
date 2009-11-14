
module RGeom
  
  module Commands

    @register ||= RGeom::Register.instance    # move @r to Commands?

    def p(*args)
      Point[*args]
    end


      # points :A => [4,1], :B => [5,-3], :C => p(3,0)
    def points(pts={})
      #@r ||= RGeom::Register.instance    # move @r to Commands?
      pts.each_pair do |name,coords|
        @register[name] = Point[coords]
      end
      nil
    end



      # midpoint(:AC)
    def midpoint(labels)
      segment(labels).midpoint
    end



    def segment(*args)
      data = Segment.parse(*args)
      Segment.construct(data)
    end



    def triangle(*args)
      # TODO the code below is necessary but ugly.  Find a way to include it
      # somewhere else.  In fact, all of these funtions triangle(), segment,
      # circle() etc. have the same pattern.  It can probably be moved to Shape.
      # Maybe Shape.create(:triangle, *args) or something.
      if args.first.to_s =~ /^([A-Z]{3})$/
        label = $1
        if t = @register.by_label(:triangle, label)
          # The user has called triange(:ABC, ...) for the second time, so
          # we return the existing triangle.
          if args.size > 1
            warn "triangle: Found existing triangle with vertices #{label}; ignoring extra arguments."
          end
          return t
        end
      end
      data = RGeom::Triangle.parse(*args)
      RGeom::Triangle.construct(data)
    end



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
    def circle(*args)
      data = RGeom::Circle.parse(*args)
      RGeom::Circle.construct(data)
    end



    def square(*args)
      data = RGeom::Square.parse(*args)
      RGeom::Square.construct(data)
    end



    def generate(*args, &block)
      Shape.generate(*args, &block)
    end



    def render(filename, *args)
      Diagram.new(filename).render(*args)
    end

  end  # module Commands

end  # module RGeom
