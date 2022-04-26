#!/bin/sh
languages=`enscript --help-highlight | grep 'Name:' | cut -d ' ' -f 2`
for l in $languages; do
    cat << EOF
  "$l" => "$l",
EOF
done
