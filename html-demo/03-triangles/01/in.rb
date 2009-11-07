points :A => p(1,4), :B => p(6,3)

triangle(:ABC, :isosceles, :side => 8)
triangle(:CBD, :equilateral)
triangle(:DBE, :scalene, :angles => [110.d, 19.d])

points :X => p(10,10)
triangle(:XYZ, :sides => [5.2,4.1,7.9])

triangle(:YEW, :right_angle => :W, :height => 1.5)

# dot(:A, :B, :C, :D, :E, :X, :Y, :Z, :label)
