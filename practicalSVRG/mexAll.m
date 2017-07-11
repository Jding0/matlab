% minFunc
fprintf('Compiling minFunc files...\n');
mex -outdir compiled mex/mcholC.c
mex -outdir compiled mex/lbfgsC.c
mex -outdir compiled mex/lbfgsAddC.c
mex -outdir compiled mex/lbfgsProdC.c

% SVRG
fprintf('Compiling SVRG files...\n');
mex -outdir compiled mex/SVRG_logistic.c -largeArrayDims
mex -outdir compiled mex/SVRG_hsvm.c -largeArrayDims
mex -outdir compiled mex/SVRG_hsvm_skip.c -largeArrayDims

