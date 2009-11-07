triangle(:ABC, :base => 10, :angles => [51.d, 73.d])
segment(:start => :A, :end => midpoint(:BC))
segment(:start => :B, :end => midpoint(:AC))
segment(:start => :C, :end => midpoint(:AB))
