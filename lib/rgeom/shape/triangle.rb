#
# triangle(:ABC)
#  - create default triangle where :AB is the base
#  - if triangle ABC already exists, simply return it
#
# triangle(:ABC, :isosceles, :base => 8)
#  - AB is the base, height is some default (e.g. 0.6 x the base)
#
# triangle(:LMK, :base => 8, :angles => [75.d, 22.d])
#  - scalene triangle with :LM as the base, and :K determined by the angles
#
# triangle(:ABC, :right => :A, :base => 3, :height => 5)
#  - AB is the base, right angle at A, base and height as given
#
# triangle(:ABD, :equilateral)
#  - base AB
#  - if A and B already exist, perfect; otherwise, use defaults
#    - A defaults to (0,0); B defaults to A + (1,0)
#
# What happens always depends on what points already exist.
module RGeom
class Triangle < Shape

  CATEGORY = :triangle

    # _vertices_ is a VertexList
    #       [ Vertex[:A, 0,0], Vertex[:B, 1,0], Vertex[:C, 0.39,0.60] ]
  attr_reader :vertices   

  require 'rgeom/shape/triangle/parse'
  require 'rgeom/shape/triangle/construct'

  def initialize(vertex_list, type)
    super(vertex_list)
    @type = type
    @points = @vertices.points
  end

  def to_s(mode=:long)
    label = @label || "(no label)"
    if mode == :short
      "Triangle #{label} " + @points.map { |p| p.to_s(1) }.join(" ")
    elsif mode == :long
      "Triangle #{label}:\n  ".green.bold + @vertices.to_s(:long)
    else
      Err.invalid_display_mode(mode)
    end
  end
  def inspect; to_s(:short); end
  def label; @label; end

  def apex
    @points.last
  end

  def base
    Segment.new(:start => @points[1], :end => points[0])
  end

  def hypotenuse
    if @type == :right_angle
      Segment.simple( @points[1], @points[2] )
    end
  end

end  # class Triangle
end  # module RGeom


