function [] = SVRGexp_run(loss)
close all

const = 1;
maxIter = 15;
switch loss
    case 'logistic'
        methods = {'Full','Grow','Mixed'};
    case 'hsvm'
        methods = {'Full','Grow','Full-SV2','Grow-SV2'};
end
trainRatio = .5;

data = cell(0,1);
%data{end+1,1} = 'statlog.heart.data';
%data{end+1,1} = 'quantum.mat';
%data{end+1,1} = 'protein.mat';
%data{end+1,1} = 'sido';
%data{end+1,1} = 'rcv1';
%data{end+1,1} = 'covertype';
%data{end+1,1} = 'news';
data{end+1,1} = 'spam';
%data{end+1,1} = 'rcv1Full';
%data{end+1,1} = 'alpha';
%data = data(end:-1:1);

for d = 1:size(data,1)
    SVRGexp_plot(data{d},loss,trainRatio,methods,maxIter);
end

