function [result] = runExp(runFunc,varargin)
rand('state',0);
randn('state',0);
resultDir = strcat('results/',func2str(runFunc));
if ~exist(resultDir,'dir')
    mkdir(resultDir);
end

%fprintf('Running experiment %s(',func2str(runFunc));
%fprintf(' %g ',varargin{:});
%fprintf(')\n');

resultFile = strcat(resultDir,'/',sprintf('%g_',varargin{:}),'.mat');
if exist(resultFile,'file')
    %fprintf('File exists\n');
    result = load(resultFile);
    result = result.result;
else
    result = runFunc(varargin{:});
    save(resultFile,'result');
end