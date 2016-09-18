#mat_file=friendster.mat
#mat_idx=friendster.mat_idx
mat_file=twitter-lcc.mat
mat_idx=twitter-lcc.mat_idx

for split in 1 2 4 8 16 32
do
	echo "IM-SpMM, each with $split cols"
	test/test-2d_multiply conf/run_test-EM.txt $mat_file $mat_idx -r 5 -w 32 -i $split -m
done

for split in 1 2 4 8 16 32
do
	echo "SEM-SpMM, each with $split cols"
	test/test-2d_multiply conf/run_test-EM.txt $mat_file $mat_idx -r 5 -w 32 -i $split -e
done
