
# This file just loads all the files that make the DSL happen.  Key things
# implemented in the DSL (these are all commands in the <tt>RGeom::Commands</tt>
# module:
#
# +shape+:: Defines a shape specification, most importantly the combinations
# (and types) of parameters that are acceptable.
#
# +datatype+:: Defines a type for use in +shape+ parameters.
#
# +value+:: Defines a value (e.g. 'origin') for use as a default parameter value.

require 'rgeom/dsl/parameter'
require 'rgeom/dsl/shape'
require 'rgeom/dsl/types'
require 'rgeom/dsl/types/parse'
