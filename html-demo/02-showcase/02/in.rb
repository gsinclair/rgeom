(0..30).each do |d|
  centre = Point[sqrt(d), sqrt(d)]
  radius = sqrt(2.2*d)
  circle(:centre => centre, :radius => radius)
end
