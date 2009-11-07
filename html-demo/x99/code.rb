# Problem of Thales: semi-circle with right-angle inscribed within

triangle(:ABC, :base => 4, :angles => [30.d, 60.d])
angle(:ACB).mark(:right)
circle(:diameter => :AB, :arc => :tophalf, :style => :light)
triangle(:ABC).label_vertices

