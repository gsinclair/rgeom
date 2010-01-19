
require 'test/unit/assertions'

module RGeom::Assertions

  DEFAULT_FLOAT_TOLERANCE = 0.0001

    # Assert close equality of two numbers (especially floats).
  def assert_close(expected, actual, tolerance=DEFAULT_FLOAT_TOLERANCE, message=nil)
    assert_in_delta(expected, actual, tolerance, message)
  end

    # May need to change first argument to vertex_list for greater generality.
  def assert_vertices(shape, args, tolerance=DEFAULT_FLOAT_TOLERANCE, message=nil)
    vertices = shape.vertices.dup
    i = -1
    args.each_slice(3) do |lbl, x, y|
      v = vertices.vertex(i += 1)
      assert_equal lbl.to_sym, v.name
      message = "Expected Point #{lbl} #{Point[x,y]}, got #{v.point}"
      assert_close Float(x), v.x, tolerance, message
      assert_close Float(y), v.y, tolerance, message
    end
  end

    # assert_circle [5,2,3,:H] asserts that the centre is (5,2), the radius is 3 and
    # the label is :H.
  def assert_circle(vals, circle)
    assert_close vals.shift, circle.centre.x, 0.00001, "x"
    assert_close vals.shift, circle.centre.y, 0.00001, "y"
    assert_close vals.shift, circle.radius, 0.00001, "r"
    assert_equal vals.shift, circle.label.safe_send(:symbol), "label"
  end

  def assert_arc(vals, arc)
    assert_circle(vals, arc)
    angles = [Float(vals.shift), Float(vals.shift)]
    assert_equal angles, arc.angles
  end

    # assert_square a_square, %(3 5   2 0   1.2 7.5   9 10)
  def assert_square(square, vals)
    square.each_vertex do |vertex|
      x = Float(vals.shift)
      y = Float(vals.shift)
      assert_point p(x,y), vertex
    end
  end

  def assert_point_equal(actual, expected)
    assert_close actual.x, expected.x
    assert_close actual.y, expected.y
  end

  alias assert_point assert_point_equal

  def assert_empty(collection)
    assert(collection.empty?)
  end

  def assert_all_nil(data, *keys)
    values = keys.map { |k| data.send(k) }
    assert_empty values.compact
  end

end  # module RGeom::Assertions

