#
# This file is a NOTEPAD for implementing the Shape Specification DSL.  No file
# will 'require' this, so it does not actually form part of the RGeom code.  It
# will be removed once these snippets have been implemented in the appropriate
# place.
#

# NOTE: The all-in-one triangle spec below would be difficult to implement.
# I'm looking at doing separate shapes (:isosceles_triangle etc.) and just
# creating a triangle() method to interface to the automatically-created methods
# isosceles_triangle(), equilateral_triangle(), etc.
shape :triangle, :label => :ABC,
  :fixed_parameters => { :type => [:equilateral, :isosceles, :scalene, :_] },
  :declaration => "base: (segment,n=nil)",
  :parameters_depend_on => :type,
  :parameters => {
    :isosceles => %{
      base
      base, height: length
      base, angle: n
      base, side: length
    },
    :equilateral => %{},  # wrong, I think; specify the base?  height even?
    :scalene => %{
      sides: [length,length,length]
      base
      base, angles: [n,n]
      base, height: length
    },
    :_ => %{
      base,  right_angle: symbol,  height: length=nil
      sas: [length,angle,length]
    }
  }

shape :isosceles_triangle, :label => :ABC,
  :declaration => "base: (segment,n=nil)",
  :parameters => %{
      (base)
      (base), height: length
      (base), angle: n
      (base), side: length
  }

shape :equilateral_triangle, :label => :ABC,
  :declaration => "base: (segment,n=nil)",
  :parameters => %{
    (base)
  }

shape :scalene_triangle, :label => :ABC,
  :declaration => "base: (segment,n=nil)",
  :parameters => %{
    sides: [length,length,length]
    (base)
    (base), angles: [n,n]
    (base), height: length
  }

shape :right_angled_triangle, :label => :ABC,
  :declaration => "base: (segment,n=nil)",
  :parameters => %{
    (base), right_angle: symbol, height: length=nil
  }

shape :sas_triangle, :label => :ABC,
  :parameters => %{
    sas: [length,angle,length]
  }

# Here endeth the triangles.

shape :circle, :label => :K,
  :parameters => %{
    centre: point=origin, radius: length=1
    centre: point=origin, diameter: length
    radius: segment
    diameter: segment
  }

shape :arc, :label => :K,
  :parameters => %{
    centre: point=origin, radius: length=1, angles: [n,n]
    centre: point=origin, diameter: length, angles: [n,n]
    radius: segment, angles: [n,n]
    diameter: segment, angles: [n,n]
  }

shape :circle, :extends => :arc

shape :segment, :label => :AB,
  :parameters => %{
    -                             | segment(:AB) -- if A and B exist, no info needed
    start: point, end: point
    p:     point, q:   point      | aliases for start and end
  }

shape :square, :label => :HIJK,
  :parameters => %{
    side: n=1
    base: segment
  }

shape :polygon, :label => "3+",
  :parameters => %{
    circle: circle=nil, n: integer(>2), rotation: angle=0
    base: segment, n: integer(>2)
  }

shape :histogram, :label => :H,
  :argument_list => %{
    xvals: range
    yvals: range
    data: ordered_pairs
    xcaption: string="x"
    ycaption: string="f"
    title: string=nil
  }

datatype :ordered_pairs { |o| o.string? and Parser.ordered_pairs(o) }

datatype :range,
  :match => [
    lambda { |o| o.range? and o.to_a },
    lambda { |o| o.string? and Parser.range(o) }
  ]

datatype :number, :alias => [:n,:angle],
  :match => lambda { |o| o.numeric? and o }

datatype :integer { |o, condition|
    if o.integer? and condition.nil?
      o
    elsif o.integer? and condition.notnil?
      o if (eval "#{o}#{condition}")
    else
      false
    end
  }

datatype :length,
  :match => [
    lambda { |o| o.numeric? and o },
    lambda { |o| o.symbol? and o.length == 2 and Segment[o].length },
    lambda { |o| o.is_a? Segment and o.length }
  ]

datatype :segment,
  :match => [
    lambda { |o| o.is_a? Segment and o },
    lambda { |o| o.symbol? and Segment[o] }  # <-- segment needn't pre-exist; we can create one so long as the points exist
  ]

datatype :circle,
  :match => [
    lambda { |o| o.is_a? Circle and o },
    lambda { |o| o.symbol? and Circle[o] }
  ]

datatype :point, :is_a => Point


value :origin,    :value => Point[0,0]
value :nil,       :value => nil
value /[0-9.-]+/, :value => lambda { |x| Integer(x) rescue Float(x) }

__END__

What happens when this code is run?

  datatype :length,
    :match => [
      lambda { |o| o.numeric? and o },
      lambda { |o| o.symbol? and o.length == 2 and Segment[o].length },
      lambda { |o| o.is_a? Segment and o.length }
    ]

The 'datatype' method calls something like this:

  Datatype.add_type :length, nil, [lambda {...}, ...]

Where...

  class RGeom::Datatype
    @@types = {
      :length => [lambda {...}, ...],
      :segment => [lambda {...}, ...],
      ...
    }
    @@aliases = { :angle => :number, :n => :number, ... }

    def Datatype.match(type, object)
      @@types[type].each do |matcher|
        value = matcher.call(object)
        return value if value.notnil?
      end
    end

    def Datatype.add_type(type, aliases, matchers)
      # ...
    end

    def Datatype.to_s
      # List the types, aliases, and how many matchers each type has.
    end
  end


OK, what about this?

  shape :circle, :label => :K,
    :parameters => %{
      centre: point=origin, radius: length=1
      centre: point=origin, diameter: length
      radius: segment
      diameter: segment
    }

We need to create:
  * class RGeom::Shape::Circle < RGeom::Shape
  * Some data structure (Arguments?) inside that class that can be used
    to implement Shape.parse_arguments(*args) -- generic functionality
    that each subclass can call.
    - Ensures the arguments given (principally a hash) match one of the
      acceptable combinations (e.g. :radius => :AV  or  :centre => :B),
      taking account of the default values.
    - The idea would be to return a Specifications object (or something new
      to take its place) containing the values that the user provided, with
      default values filled in and casts (e.g. :AB -> Segment[:AB]) having
      been done.
    - Of course, if the user didn't provide an acceptable argument list, an
      error is raised.  It could be:
        + Unsupported argument included (:froboz => -2)
        + Unacceptable combination (:radius => 5, :diameter => :VQ)
        + Type error (:radius => "schnell")
        + Condition error (:diameter => -3) -- doesn't violate above spec (yet)
        + Specification error (:radius => :AB but no point B)
          * Note: don't need preexisting Segment AB: just points A and B will do

With validation and data-bundling handled automatically, the programmer is free
to implement Circle.construct(data) without worrying about the correctness of
the data given.  It can be simply an OpenStruct, in fact.  Or I could create Data
objects based on the "shape :circle ..." if there's a benefit to that.  A plain
OpenStruct should be fine, though: you know there's no general validation problem,
so ...


