#!/bin/sh

out="OBJECTS="

files=`ls src/*.c | grep -v "test" | sed -e "s/\.c$/\.o/g" | sed -e "s/^src\///g"`
for I in $files
do
	out=$out"$I "
done

files=`ls src/*.cpp | grep -v "test" | sed -e "s/\.cpp$/\.o/g" | sed -e "s/^src\///g"`
for I in $files
do
	out=$out"$I "
done

files=`find src/FlashX/matrix/ -name "*.cpp" | grep -v "test" | sed -e "s/\.cpp$/\.o/g" | sed -e "s/^src\///g"`
for I in $files
do
	out=$out"$I "
done

files=`find src/FlashX/libsafs/ -name "*.cpp" | grep -v "test" | sed -e "s/\.cpp$/\.o/g" | sed -e "s/^src\///g"`
for I in $files
do
	out=$out"$I "
done

echo $out
