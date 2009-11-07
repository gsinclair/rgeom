require 'test/unit'
require 'rgeom'
include RGeom::Assertions
include RGeom

class TestVertexList < Test::Unit::TestCase

  def setup
    @register = RGeom::Register.instance
    @register.clear!
  end

  def test_1_basic_initialize
    VertexList.new(3, [:X, :Y, :Z], [p(1,1), p(5,1), p(3,3)]).tap do |vl|
      assert_equal p(1,1), vl[0]
      assert_equal p(5,1), vl[1]
      assert_equal p(3,3), vl[2]
      assert_equal :XYZ, vl.label
      assert_equal [:X, :Y, :Z], vl.vertex_names
      assert_equal PointList[p(1,1), p(5,1), p(3,3)], vl.pointlist
      assert_equal "TTT", vl.mask
    end
  end

  def test_2_enforce_number_of_vertices
    assert_raise(ArgumentError) do
      VertexList.new(5, [:X, :Y, :Z], [p(1,1), p(5,1), p(3,3)])
    end
  end

  def test_3_resolve_1
    points :A => p(3,1), :B => p(9,7)
    VertexList.resolve(2, :AB).tap do |vl|
      assert_equal p(3,1), vl[0]
      assert_equal p(9,7), vl[1]
      assert_equal :AB, vl.label
      assert_equal [:A, :B], vl.vertex_names
      assert_equal PointList[p(3,1), p(9,7)], vl.pointlist
      assert_equal "TT", vl.mask
    end
  end

    # Points X, Y and Z are not defined.  Calling VertexList.resolve(3, :XYZ) will
    # generate a vertex list with +nil+ points.  Calling accommodate(...) will assign the
    # points to the vertices.  A side effect, which we test, is that the register is
    # updated with those point definitions.
  def test_4_resolve_and_accommodate_1_all_points_nil
    VertexList.resolve(3, :XYZ).tap do |vl|
      assert_equal nil, vl[0]
      assert_equal nil, vl[1]
      assert_equal nil, vl[2]
      assert_equal nil, @register[:X]
      assert_equal nil, @register[:Y]
      assert_equal nil, @register[:Z]

      vl.accommodate [p(4,3), p(1,0), p(5,5)]
      assert_equal p(4,3), vl[0]
      assert_equal p(1,0), vl[1]
      assert_equal p(5,5), vl[2]
      assert_equal p(4,3), @register[:X]
      assert_equal p(1,0), @register[:Y]
      assert_equal p(5,5), @register[:Z]
    end
  end

  def test_5_resolve_and_accommodate_2_some_points_defined
    points :A => p(3,1), :B => p(9,7)
    VertexList.resolve(4, :ABCD).tap do |vl|
      assert_equal :ABCD,  vl.label
      assert_equal p(3,1), vl[0]
      assert_equal p(9,7), vl[1]
      assert_equal nil,    vl[2]
      assert_equal nil,    vl[3]
      assert_equal nil,    @register[:C]
      assert_equal nil,    @register[:D]

      vl.accommodate [nil, nil, p(4,5), p(0,0)]
      assert_equal p(3,1), vl[0]
      assert_equal p(9,7), vl[1]
      assert_equal p(4,5), vl[2]
      assert_equal p(0,0), vl[3]
      assert_equal p(4,5), @register[:C]
      assert_equal p(0,0), @register[:D]
    end
  end

  def test_6_update_success_and_error
    points :A => p(3,1)
    VertexList.resolve(4, :ABC_).tap do |vl|
      assert_equal :ABC_,  vl.label
      assert_equal p(3,1), vl[0]
      assert_equal nil,    vl[1]
      assert_equal nil,    vl[2]
      assert_equal nil,    vl[3]
      assert_equal nil,    @register[:B]
      assert_equal nil,    @register[:C]

      vl[1] = p(5,6)    # update point B
      assert_equal p(5,6), vl[1]
      assert_equal p(5,6), @register[:B]

      vl[3] = p(0,-2)   # update point _
      assert_equal p(0,-2), vl[3]
      
      assert_raise(ArgumentError) do
        vl[0] = p(4,2)    # update point A: error, already defined
      end
    end
  end

  def test_7_successive_accommodates
    points :A => p(3,1)
    VertexList.resolve(4, :ABC_).tap do |vl|
      vl.accommodate [p(3,1), p(2,2)]
      assert_equal p(3,1), vl[0]
      assert_equal p(2,2), vl[1]
      assert_equal nil,    vl[2]
      assert_equal nil,    vl[3]
      vl.accommodate [p(3,1), p(2,2), p(1,9)]
      assert_equal p(3,1), vl[0]
      assert_equal p(2,2), vl[1]
      assert_equal p(1,9), vl[2]
      assert_equal nil,    vl[3]
      vl.accommodate [p(3,1), p(2,2), p(1,9), p(5,2)]
      assert_equal p(3,1), vl[0]
      assert_equal p(2,2), vl[1]
      assert_equal p(1,9), vl[2]
      assert_equal p(5,2), vl[3]
    end
  end

  def test_8_default_label
    VertexList.new(3, nil, nil).tap do |vl|
      assert_equal :___, vl.label
      debug vl
    end
    VertexList.new(5, nil, nil).tap do |vl|
      assert_equal :_____, vl.label
      debug vl
    end
  end

  def test_9_default_resolve
    VertexList.resolve(5, nil).tap do |vl|
      assert_equal nil, vl[0]
      assert_equal nil, vl[1]
      assert_equal nil, vl[2]
      assert_equal nil, vl[3]
      assert_equal nil, vl[4]
    end
  end

end  # class TestVertexList

