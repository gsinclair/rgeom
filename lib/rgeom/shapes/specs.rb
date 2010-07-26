#
# This file contains specifications (using the DSL) of the basic inbuilt shapes
# (one at a time while I'm testing).  Could be renamed "builtins" or something
# later on.
#
# This code will be executed simply by a program (or test suite) executing
#
#   require 'rgeom'
#
# Will it work??!?
#

  # It's not nice to have to include this (or doesn't it matter?).
  # Should 'shape' be defined in RGeom::Commands?  Time will tell.
include RGeom::DSL


  # It's not nice to have to include these either, but otherwise
  # Point, Segment etc. don't make any sense.
include RGeom::Shapes
include RGeom

datatype :point,
  :match => [
    lambda { |o| o.is_a? Point and o },
    lambda { |o| o.symbol? and Point[o] }
  ]

datatype :length,
  :match => [
    lambda { |o| o.numeric? and o },
    lambda { |o| o.symbol? and o.length == 2 and Segment.from_symbol(o).length },
    lambda { |o| o.is_a? Segment and o.length }
  ]

datatype :segment,
  :match => [
    lambda { |o| o.is_a? Segment and o },
    lambda { |o| o.symbol? and Segment.from_symbol(o) },
    lambda { |o| o.is_a? Array and o.map { |x| x.class } == [Point, Point] \
                               and Segment.simple(*o)}
  ]

datatype :number, :alias => [:n,:angle],
  :match => lambda { |o| o.numeric? and o }

datatype :symbol,
  :match => lambda { |o| o.symbol? and o }

value "origin",   :value => Point[0,0]
value "nil",      :value => nil
value /[0-9.-]+/, :value => lambda { |x| Integer(x) rescue Float(x) }

shape :circle, :label => :K,
  :parameters => %{
    radius: segment
    diameter: segment
    centre: point=origin, radius: length=1
    centre: point=origin, diameter: length
  }

shape :arc, :label => :K,
  :parameters => %{
    radius: segment, angles: [n,n]
    diameter: segment, angles: [n,n]
    centre: point=origin, radius: length=1, angles: [n,n]
    centre: point=origin, diameter: length, angles: [n,n]
    centre: point, radius: length, from: point, to: point
  }

  # For a semicircle, 'diameter' and 'base' are synonyms.
shape :semicircle, :label => :K,
  :parameters => %{
    base: segment=nil
    diameter: segment
    radius: segment
  }

  # We don't know how many vertices a polygon has.
  # Perhaps we'll have to implement Shape.valid_label?(label).
  # (That would give us Triangle.valid_label?, Polygon.valid_label? etc.)
shape :polygon, :label => :_,
  :declaration => "base: (segment,n=nil)",
  :parameters => %{
    n: number, (base), start: point=nil
    n: number, centre: point=origin, radius: length
  }

shape :segment, :label => :AB,
  :parameters => %{
    -
    start: point, end: point
    p: point, q: point
  }

shape :square, :label => :HIJK,
  :parameters => %{
    -
    side: n
    base: segment
    diagonal: segment
  }

shape :triangle, :label => :ABC,
  :fixed_parameter => :type,
  :declaration => "base: (segment,n=nil)",
  :parameters => {
    :isosceles => %{
      (base)
      (base), height: length
      (base), angle: n
      (base), side: length
    },
    :equilateral => %{
      (base)
    },
    :scalene => %{
      (base)
      sides: [length,length,length]
      (base), angles: [n,n]
      (base), height: length
    },
    :_ => %{
      (base)
      (base), right_angle: symbol, height: length=nil, slant: symbol=nil
      sides: [length,length,length]
      (base), angles: [n,n]
      (base), height: length
      sas: [length,angle,length]
    }
  }


#debug "End of specs.rb"
