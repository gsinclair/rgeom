require 'test/unit'
require 'rgeom'
include RGeom
include RGeom::Assertions


class TestTriangleParse < Test::Unit::TestCase

  def setup
    @verbose = false
    debug ''
    @register = RGeom::Register.instance
    @register.clear!
  end

  def test_01
    data = Triangle.parse(:ABC)
    assert_equal [:A, :B, :C], data.vertex_list.vertex_names
    assert_equal [nil, nil, nil], data.vertex_list.points
    assert_equal 'FFF', data.vertex_list.mask
    assert_equal nil, data.type
    assert_all_nil(data, :base, :height, :angles, :sides, :right_angle, :sas)
    #assert_empty data.givens
    assert_empty data.unprocessed 
    debug data if @verbose
  end

  def test_02
    data = Triangle.parse(:GMK, :isosceles, :base => 8)
    assert_equal :GMK, data.label.symbol
    assert_equal [:G, :M, :K], data.vertex_list.vertex_names
    assert_equal [nil, nil, nil], data.vertex_list.points
    assert_equal :isosceles, data.type
    assert_equal 8, data.base
    assert_all_nil(data, :height, :angles, :sides, :right_angle, :sas)
    #assert_equal Set[:isosceles, :base], data.givens
    assert_empty data.unprocessed 
    debug data if @verbose
  end

  def test_03
    data = Triangle.parse(:LMK, :base => 17, :angles => [75.d, 22.d])
    assert_equal [:L, :M, :K], data.vertex_list.vertex_names
    assert_equal [nil, nil, nil], data.vertex_list.points
    assert_equal nil, data.type
    assert_equal 17, data.base
    assert_equal [75.d, 22.d], data.angles
    assert_all_nil(data, :height, :sides, :right_angle, :sas)
    #assert_equal Set[:base, :angles], data.givens
    assert_empty data.unprocessed 
    debug data if @verbose
  end

  def test_04
    data = Triangle.parse(:ABC, :right_angle => :A, :base => 3, :height => 5)
    assert_equal [:A, :B, :C], data.vertex_list.vertex_names
    assert_equal [nil, nil, nil], data.vertex_list.points
    assert_equal :right_angle, data.type
    assert_equal :A, data.right_angle
    assert_all_nil(data, :angles, :sides, :sas)
    #assert_equal Set[:right_angle, :base, :height], data.givens
    assert_empty data.unprocessed
    debug data if @verbose
  end

  def test_05
    data = Triangle.parse(:ABD, :equilateral, :yellow)
    assert_equal [:A, :B, :D], data.vertex_list.vertex_names
    assert_equal :equilateral, data.type
    assert_all_nil(data, :base, :height, :angles, :sides, :right_angle, :sas)
    #assert_equal Set[:equilateral], data.givens
    assert_equal Hash[:yellow => :yellow], data.unprocessed 
    debug data if @verbose
  end

  def test_06
    data = Triangle.parse(:XYZ, :sides => [5,6,7],
			  :colour => :red, :style => :dashed)
    assert_equal [:X, :Y, :Z], data.vertex_list.vertex_names
    assert_equal nil, data.type
    assert_equal [5,6,7], data.sides
    assert_all_nil(data, :base, :height, :angles, :right_angle, :sas)
    #assert_equal Set[:sides], data.givens
    assert_equal Hash[:colour => :red, :style => :dashed], data.unprocessed 
    debug data if @verbose
  end

  def test_07
    data = Triangle.parse(:CKT, :sas => [10,22.d,11])
    assert_equal [10,22.d,11], data.sas
    debug data if @verbose
  end

  def test_08_isosceles_with_just_one_side
    data = Triangle.parse(:AMV, :isosceles, :base => 5, :side => 4)
    assert_equal :isosceles, data.type
    assert_equal 5, data.base
    assert_equal 4, data.side
    debug data if @verbose
  end

  def test_09_isosceles_with_just_one_angle
    data = Triangle.parse(:AM_, :isosceles, :base => 5, :angle => 40.d)
    assert_equal [:A, :M, :_], data.vertex_list.vertex_names
    assert_equal :isosceles, data.type
    assert_equal 5, data.base
    assert_equal 40.d, data.angle
    debug data if @verbose
  end

  def test_10_triangle_with_anonymous_points
    data = Triangle.parse(:base => [p(1,1), p(5,3)], :right_angle => :apex, :height => 3)
    assert_equal nil, data.label.symbol
    assert_equal [:_, :_, :_], data.vertex_list.vertex_names
    assert_equal [p(1,1), p(5,3), nil], data.vertex_list.points
    assert_equal nil, data.base
    assert_equal :right_angle, data.type
    assert_equal :apex, data.right_angle
    assert_equal 3, data.height
    debug data if @verbose
  end

  def test_11_triangle_with_base_as_interval
    data = Triangle.parse(:base => :CY, :angles => [45.d, 21.d])
    assert_equal nil, data.label.symbol
    assert_equal [nil, nil, nil], data.vertex_list.points
    assert_equal [:_, :_, :_], data.vertex_list.vertex_names
    assert_equal nil, data.base
    assert_equal nil, data.type
    assert_equal [45.d, 21.d], data.angles
    debug data if @verbose
  end

end
