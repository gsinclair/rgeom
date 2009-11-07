# Problem of Thales: semi-circle with right-angle inscribed within

# Code:
#
# triangle(:ABC, :base => 4, :angles => [30.d, 60.d])
# angle(:ACB).mark(:right)
# circle(:diameter => :AB, :arc => :tophalf, :style => :light)
# triangle(:ABC).label_vertices

# This file describes the kind of things that should be in the Diagram.

A = point(0,0)      # by default
B = point(4,0)      # because base of triangle = 4
C = point(3,1.732)  # because of base angles

right_angle(:ACB)   # A right angle is to be marked

arc([2,0], 2, [0, 180])[:lightgrey]

label("A", point[:A], 193.1)   # 193.1 degrees, based on centroid of triangle
label("B", point[:B], 340.9)
label("C", point[:C], 60)
