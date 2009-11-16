shape :square, :fields => [:side, :base]

shape :triangle, :fields => [:base, :height, :sas, :angles, :sides]

post_process :triangle do |data|
  # get fields in order...
end

construct :square do |data|
  # ...
end


