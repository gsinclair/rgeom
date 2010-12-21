module RGeom

  # Arc and Circle are similar objects, but the DSL does not allow a class
  # hierarchy.  This module is a way for them to share methods.
  #
  # @circle and @radius are required.
  module CircleArcCommon

    # Given an angle (Angle), return the point on the circumference at that
    # angle.  (Angles start at East and go anti-clockwise, as usual.)
    def point(theta)
      Point.polar(radius, theta).translate(centre)
    end

    # Given a point on the circumference (ostensibly; doesn't matter if it is),
    # return the angle from the centre (in radians).
    def angle_at(point)
      Point.angle(centre, point)
    end

    def interpolate(k)
      a, b = @absolute_angles || [0.d,360.d]
      angle = a + (b-a)*k
      point(angle)
    end

      # A circle or arc doesn't have vertices, but it does have a defining
      # point, and a Shape object must give a good answer when asked what its
      # vertices are.
    def vertices
      VertexList.new(1, nil, [@centre])
    end

  end  # module CircleArcCommon
 
end  # module RGeom
