
LinearMap = RGeom::Diagram::Canvas::LinearMap

D "LinearMap" do

  ### def T :linearmap,(map, values={})
  ###   values.each_pair do |x, x_|
  ###     assert_close x_, map.map(x)
  ###   end
  ### end

  ### def debug_map(map, range)
  ###   range.each do |i|
  ###     debug [i, map.map(i)].inspect
  ###   end
  ### end

  D "test 1" do
    map = LinearMap.new(1..10, 5..14)
    T :linearmap, map, 1 => 5, 2 => 6, 3 => 7, 4 => 8, 5 => 9,
                       6 => 10, 7 => 11, 8 => 12, 9 => 13, 10 => 14
  end

  D "test 2" do
    map = LinearMap.new(0..10, 0..20)
    T :linearmap, map, 0 => 0, 10 => 20, 3 => 6, 5 => 10, 9.4 => 18.8
  end

  D "test 3" do
    map = LinearMap.new(5..7, 83..100)
    T :linearmap, map, 5 => 83, 7 => 100
    T :linearmap, map, 0 => 40.5
    T :linearmap, map, 5.27 => 85.295, 6.1928 => 93.1388
  end

  D "test 4" do
    map = LinearMap.new(0..100, 100..0)
    T :linearmap, map, 0 => 100, 100 => 0
    T :linearmap, map, 10 => 90, 25 => 75, 50 => 50, 75 => 25, 90 => 10
    T :linearmap, map, 13.935 => 86.065
  end

  D "test 5" do
    map = LinearMap.new(4.2..-1.7, 0..928)
    T :linearmap, map, 4.2 => 0, -1.7 => 928
    T :linearmap, map, 2.5 => 267.3898305
  end

end  # "LinearMap"
