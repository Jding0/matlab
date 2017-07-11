function [minVal] = SVRGgetGroundTruth(data,loss,trainRatio)
randn('state',0);
rand('state',0);

fprintf('Loading Data and setting up objective...');
standardize = 1;
addBias = 1;
[X,y] = loadd(data,standardize,addBias);
[n,nVars] = size(X);

if trainRatio ~= 1
    ind = randperm(n);
    trainNdx = ind(1:ceil(n/2));
    testNdx = ind(ceil(n/2)+1:end);
    Xtest = X(testNdx,:);
    ytest = y(testNdx);
    X = X(trainNdx,:);
    y = y(trainNdx);
    n = length(y);
end

w = zeros(nVars,1);
lambda = 1;

switch loss
    case 'logistic'
        funObj = @(w)LogisticLoss(w,X,y);
    case 'hsvm'
        funObj = @(w)HSVMLoss(w,X,y,.5);
end

options.maxIter = 1000;
options.maxFunEvals = 1000;
options.Display = 'Full';
%options.DerivativeCheck = 'on';
options.Corr = 10;
fprintf('Approximating optimal solution...\n');
w = minFunc(@penalizedL2,w,options,funObj,lambda/2);
minVal = (1/n)*funObj(w) + (1/n)*(lambda/2)*(w'*w);