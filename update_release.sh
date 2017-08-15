#!/bin/sh

git checkout dev
find -name "*~"  | xargs rm
tmp_dir=`mktemp -d "/tmp/FlashR.XXXXXXX"`
cp -R * $tmp_dir

git checkout master
mv src/boost/ $tmp_dir/src
rm -R *
mv $tmp_dir/* .
