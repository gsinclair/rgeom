# RGeom -- create geometric diagrams with Ruby
# 
# Simple example:
#
#   require 'rgeom'
#   triangle(:ABC, :equilateral)
#   render('triangle.png')
#
# See http://rgeom.rubyforge.org for more examples, including code and images.



# *----------------* General-purpose includes *----------------*

require 'debuglog'

time('rgeom -- external requires') {
require 'rubygems'
require 'yaml'
require 'pp'
require 'fattr'    # Ara Howard's souped-up attributes
require 'singleton'
require 'term/ansicolor'
require 'dictionary'
require 'facets/string/tabto'
require 'ostruct'
require 'ruby-debug'
gem 'awesome_print'
require 'ap'
}
class String; include Term::ANSIColor; end



# *----------------* Class and module directory *----------------*

time('rgeom -- internal requires') {
module RGeom

  class Err; end         # Errors that can be raised.
  require 'rgeom/err'
  require 'rgeom/err/dsl'

  require 'rgeom/support'
  include Support        # This modifies some built-in classes.

  class Label; end
  require 'rgeom/label'

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

  class Shape; end       # Superclass of anything that can be drawn.
  require 'rgeom/shape'

  module Shapes; end     # Container for builtin shapes.

  class Shapes::Segment < Shape; end
  require 'rgeom/shapes/segment' # Segment is required for the DSL.

  require 'rgeom/dsl'            # A DSL for specifying shapes and their parameters.
  require 'rgeom/shapes/specs'   # Specifications of the inbuilt shapes.

  require 'rgeom/shapes/segment' # Segment implementation (already required above)
  require 'rgeom/shapes/circle'  # Circle implementation
  require 'rgeom/shapes/arc'     # etc.
  require 'rgeom/shapes/semicircle'
  require 'rgeom/shapes/square'
  require 'rgeom/shapes/triangle'

  module Commands; end           # pt(), seg(), render(), etc.
  require 'rgeom/commands'       # For inclusion in top-level.

end  # module RGeom
}  # time()


# *----------------* Load all RGeom code *----------------*

include RGeom::Commands

