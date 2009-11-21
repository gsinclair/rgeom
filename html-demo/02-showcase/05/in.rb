circle :radius => 3

# Create a series of arcs starting at the given angles and continuing
# for 40 degrees.
[-60, 60, 180].each do |angle|
  arc1 = arc :radius => 4,  :angles => [angle, angle+60]
  arc2 = arc :radius => 12, :angles => [angle, angle+60]
  segment :p => arc1.start, :q => arc2.start
  segment :p => arc1.end,   :q => arc2.end
end
