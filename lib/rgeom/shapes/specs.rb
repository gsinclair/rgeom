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

datatype :number, :alias => [:n],
  :match => lambda { |o| o.numeric? and o }

datatype :angle, :alias => [:a],
  :match => lambda { |o| o.is_a? Angle and o }

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
    radius: segment, angles: [a,a]
    diameter: segment, angles: [a,a]
    centre: point=origin, radius: length=1, angles: [a,a]
    centre: point=origin, diameter: length, angles: [a,a]
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
  
# Polygon use cases outlined in the test code:
#
#   polygon(:ABXYZ) 
#   polygon(:n => 6, :side => 2.5) 
#   polygon(:n => 3, :base => :AX) 
#   polygon(:n => 4, :centre => :A, :radius => 2) 
#   polygon(:n => 4, :radius => :AX) 
#   polygon(:n => 3, :diameter => :AC) 
#   polygon(:MNP, :n => 3, :diameter => :AC) 
#   polygon(:CWXYZ, :side => 10) with existing C 
#   polygon(:CBHI) with existing C and B 

shape :polygon, :label => "3+",
  :parameters => %{
    -
    n: number, side: length
    n: number, base: segment
    n: number, radius: segment
    n: number, diameter: segment
    n: number, centre: point=origin, radius: length
    n: number, centre: point=origin, diameter: length
    base: length
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
      (base), angle: angle
      (base), side: length
    },
    :equilateral => %{
      (base)
    },
    :scalene => %{
      (base)
      sides: [length,length,length]
      (base), angles: [a,a]
      (base), height: length
    },
    :_ => %{
      (base)
      (base), right_angle: symbol, height: length=nil, slant: symbol=nil
      sides: [length,length,length]
      (base), angles: [a,a]
      (base), height: length
      sas: [length,angle,length]
    }
  }


#debug "End of specs.rb"
