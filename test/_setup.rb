
require 'rgeom'
require 'debuglog'
require 'ruby-debug'

# Usage:
#   T :circle, c, [5,2, 3, :H]
# Asserts that:
#   centre is (5,2)
#   radius is 3
#   label  is :H    (actually, Label[:H])
Attest.custom :circle, {
  :description => "Circle equality",
  :parameters  => [ [:circle, Circle], [:values, Array] ],
  :run => proc {
    x, y, r, label = values
    test('x')     { Ft circle.centre.x,  x, 0.001     } 
    test('y')     { Ft circle.centre.y,  y, 0.001     }
    test('r')     { Ft circle.radius,    r, 0.001     }
    test('label') { Eq circle.label,     Label[label] } 
  }
}

# Usage:
#   T :arc, c, [5,2, 3, :H, 30,105]
# Asserts that:
#   centre is (5,2)
#   radius is 3
#   label  is :H    (actually, Label[:H])
#   angles are [30,105]
Attest.custom :arc, {
  :description => "Arc equality",
  :parameters  => [ [:arc, Arc], [:values, Array] ],
  :run => proc {
    x, y, r, label, a1, a2 = values
    test('x')      { Ft arc.centre.x, x, 0.001     }
    test('y')      { Ft arc.centre.y, y, 0.001     }
    test('r')      { Ft arc.radius,   r, 0.001     }
    test('label')  { Eq arc.label,    Label[label] }
    test('angles') { Eq arc.angles,   [a1,a2]      }
  }
}

# Usage
#   T :square, s, %w(3 5   2 0   1.2 7.5   9 10)
# It checks the four vertices of the square.
Attest.custom :square, {
  :description => "Square equality",
  :parameters => [ [:square, Square], [:values, Array] ],
  :check => proc { values.size == 8 and values.all? { |v| Numeric === v } },
  :run => proc {
    n = 0
    square.each_vertex do |vertex|
      x = Float(values.shift)
      y = Float(values.shift)
      expected_point = Point[x,y]
      test("vertex ##{n}") { Eq vertex, expected_point }
      n += 1
    end
  }
}

Attest.custom :vertices, {
  :description => "Vertices",
  :parameters => [ [:shape, Shape], [:values, Array] ],
  :run => proc {
    vertices = shape.vertices.dup
    i = -1
    values.each_slice(3) do |lbl, x, y|
      v = vertices.vertex(i += 1)
      test("vertex #{i} name")  { Eq v.name, lbl.to_sym }
      test("vertex #{i} x")     { Ft v.x, Float(x), 0.0001 }
      test("vertey #{i} y")     { Ft v.y, Float(y), 0.0001 }
    end
  }
}

Attest.custom :point, {
  :description => "Point equality",
  :parameters => [ [:point1, Point], [:point2, Point] ],
  :run => proc {
    test('x') { Ft point1.x, point2.x, 0.001 }
    test('y') { Ft point1.y, point2.y, 0.001 }
  }
}

LinearMap = RGeom::Diagram::Canvas::LinearMap

Attest.custom :linearmap, {
  :description => "Linear map correctness",
  :parameters  => [ [:map, LinearMap], [:values, Hash] ],
  :run => proc {
    values.each_pair do |x, x_|
      test("#{x} -> #{x_}") { Ft map.map(x), x_ }
    end
  }
}

