
module RGeom::Shapes
    # The 'semicircle' command actually creates an Arc object.
  class Semicircle
    def Semicircle.construct(spec)
      if spec.parameters == [:base]
        spec.diameter = spec.base || Segment.simple( p(-1,0), p(1,0 ) )
        spec.base = nil
        spec.parameters = [:diameter]
      end
      spec.angles = [0,180]
      spec.parameters += [:angles]
      Arc.construct(spec)
    end
  end  # class Semicircle
end  # module RGeom::Shapes
