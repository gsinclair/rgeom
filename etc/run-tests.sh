#
# This file is quite unnecessary now.
#
# To run tests:
#   ruby -W0 -Ilib test/all.rb [filter]
#   # or just: rt [filter]  (see etc/aliases)
#

word=${1:-.}

if [ "$1" == "all" ]; then
  # Run the whole test-suite using 'turn'
  ruby -rubygems -W0 -Ilib test/ts_all.rb
else
  # Choose an individual file to run
  files=`find test -type f | grep .rb$ | grep -v ts_all | grep $word`
  for file in $files; do
    echo
    echo --------------------------------
    echo $file
    echo --------------------------------
    ruby -rubygems -W0 -Ilib $file --use-color
    echo
  done
fi

