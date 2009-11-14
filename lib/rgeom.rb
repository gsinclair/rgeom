# RGeom -- create geometric diagrams with Ruby
# 
# Example:
#
#   require 'rgeom'
#
#   triangle(:ABC, :equilateral)
#
#   render('triangle.png')



# *----------------* General-purpose includes *----------------*

require 'rubygems'
require 'set'
require 'yaml'
require 'pp'
require 'extensions/object'
require 'extensions/enumerable'
require 'extensions/string'
require 'fattr'    # Ara Howard's souped-up attributes
require 'singleton'
require 'ruby-debug'
require 'dev-utils/debug'
require 'term/ansicolor'
require 'facets/dictionary'

class String; include Term::ANSIColor; end



# *----------------* Class and module directory *----------------*

module RGeom

  class Err; end         # Errors that can be raised.
  require 'rgeom/err'

  class Row; end         # What the register stores.
  class Register; end    # Keeps track of geometric constructs.
  require 'rgeom/register'

  class Diagram; end     # Keeps track of drawing instructions for later rendering.
  require 'rgeom/diagram'
  
  class Point; end
  class PointList; end   # Perform operations on a list of points.
  require 'rgeom/point'

  class Vertex; end      # A point with a name.
  class VertexList; def initialize(a,b); end; end
  require 'rgeom/vertex'

  class Shape; end
  require 'rgeom/shape'

  class Segment < Shape; end
  require 'rgeom/shape/segment'

  class Triangle < Shape; end
  require 'rgeom/shape/triangle'

  class Circle < Shape; end
  require 'rgeom/shape/circle'

  class Square < Shape; end
  require 'rgeom/shape/square'
  # etc.

  module Commands; end   # triangle(), circle(), p(), etc. (for inclusion to top-level).
  require 'rgeom/commands'

  module Support
    class ArgumentProcessor; end
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
    class ::Symbol
        # :ABC -> [:A, :B, :C]
      def split; self.to_s.split(//).map { |c| c.to_sym }; end
      def length; to_s.length; end
    end
    class Util
        # :XMP => "MPX"
      def Util.sort_symbol(sym)
        sym.to_s.split(//).sort.join
      end
    end
  end

  include Support

  module Assertions; end  # For testing.
  require 'rgeom/assertions'
end



# *----------------* Load all RGeom code *----------------*

include RGeom::Commands

