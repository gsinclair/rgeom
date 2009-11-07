first = triangle(:right_angle => :first, :base => 3, :height => 1)
generate(10, first) { |tn|
  base = tn.hypotenuse.reverse
  triangle(:right_angle => :first, :base => base, :height => 1)
}

Triangle[-1].hypotenuse.length == Math.sqrt(19)   # true
