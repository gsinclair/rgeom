
# Load all the unit tests, or the ones that match the filter provided.
# Assume current directory is 'rgeom'.

require 'rubygems'
gem 'test-unit', '1.2.3'
require 'test/unit'
require 'turn'

# The first argument allows us to decide which file(s) get loaded.
filter = Regexp.compile(ARGV.first || '.')

Dir['test/**/*.rb'].grep(filter).each do |file|
  next if file == "test/all.rb"
  load file
end

# Tests will run automatically and make use of TURN's nice output.
