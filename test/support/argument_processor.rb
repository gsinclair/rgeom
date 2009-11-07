require 'test/unit'
require 'rgeom'

# Given arguments:
#   :ABC, :scalene, :dashed, :blue, { :base => 8, :angles => [13, 75] }
#
# We can do:
#   extract_vertices       # -> [:A, :B, :C]
#   extract(:isosceles, :equilateral, :scalene)    # -> :scalene
#   extract(:base)                                 # -> 8
#   extract(:dashed)                               # -> :dashed
#   extract(:angles)                               # -> [13, 75]
#   extract(:nonexistent)                          # -> nil
#   givens(...)            # -> [:ABC, :scalene, :dashed, :base, :angles]
#                          # Note: blue does not appear because it was never
#                            asked for.  And the keys :base and :angles are
#                            included but not their values.

class TestArgumentProcessor < Test::Unit::TestCase
  def setup
    args =
      [ :ABC, :scalene, :dashed, :blue, { :base => 8, :angles => [13, 75] } ]
    @a = ArgumentProcessor.new args
  end

  def teardown
    @a = nil
    GC.start
  end

  def test_1
    assert_equal :ABC, @a.extract_label(3)
    custom_assert_givens
  end

  def test_2
    assert_equal :scalene, @a.extract(:isosceles, :equilateral, :scalene)
    assert_equal Set[:scalene], @a.processed
    custom_assert_givens
  end

  def test_3
    assert_equal 8, @a.extract(:base)
    assert_equal Set[:base], @a.processed
    custom_assert_givens
  end

  def test_4
    assert_equal :dashed, @a.extract(:dashed)
    assert_equal Set[:dashed], @a.processed
    custom_assert_givens
  end

  def test_5
    assert_equal [13,75], @a.extract(:angles)
    assert_equal Set[:angles], @a.processed
    custom_assert_givens
  end

  def test_6
    assert_equal nil, @a.extract(:nonexistent)
    assert_equal Set[], @a.processed
    custom_assert_givens
  end

  def test_contains
    assert @a.contains? :ABC
    assert @a.contains? :base
    assert @a.contains? :dashed
    assert @a.contains? :angles
    assert @a.contains? :scalene
  end

  def test_extract_everything
    assert_equal :ABC, @a.extract_label(3)
    assert_equal :scalene, @a.extract(:isosceles, :equilateral, :scalene)
    assert_equal 8, @a.extract(:base)
    assert_equal :dashed, @a.extract(:dashed)
    assert_equal :blue, @a.extract(:blue)
    assert_equal [13,75], @a.extract(:angles)
    assert_equal nil, @a.extract(:nonexistent)
    assert_equal Set[:scalene, :base, :blue, :dashed, :angles, :ABC], @a.processed
    assert_equal Hash[], @a.unprocessed
    custom_assert_givens
  end

  def test_extract_some_things_1
    assert_equal :scalene, @a.extract(:isosceles, :equilateral, :scalene)
    assert_equal :dashed, @a.extract(:dashed)
    assert_equal nil, @a.extract(:nonexistent)
    assert_equal Set[:scalene, :dashed], @a.processed
    assert_equal Hash[:blue => :blue, :base => 8,
	              :angles => [13,75], :ABC => :ABC], @a.unprocessed
    custom_assert_givens
  end

  def test_extract_some_things_2
    assert_equal :ABC, @a.extract_label(3)
    assert_equal 8, @a.extract(:base)
    assert_equal [13,75], @a.extract(:angles)
    assert_equal Set[:ABC, :base, :angles], @a.processed
    assert_equal Hash[:scalene => :scalene, :dashed => :dashed,
	              :blue => :blue], @a.unprocessed
    custom_assert_givens
  end

  def custom_assert_givens
    givens = @a.givens(:scalene, :equilateral, :isosceles, :base, :angles, :sides, :right)
    assert_equal Set[:scalene, :base, :angles], givens
  end

end
