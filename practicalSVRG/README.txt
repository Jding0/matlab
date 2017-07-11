To reproduce the experiments in the main paper, switch to the "practicalSVRG" directory in Matlab and type:
>> addpath(genpath(pwd)) % Adds all directories to path
>> mexAll % Compiles mex files
>> SVRGexp_run('logistic') % Runs logistic regression experiment
>> SVRGexp_run('hsvm') % Runs Huberized-SVM experiment

Note that the code saves the results to the "results" directory, and if you call it again it will just load the results from this folder. If you want to re-run, you will have to delete the files in those directories.

Cheers,

Mark