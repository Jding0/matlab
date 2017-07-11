function [result] = SVRGexp(data,loss,trainRatio,method,maxIter,stepSize)
fprintf('Running %s on %s (stepSize = %f)\n',method,data,stepSize);
randn('state',0);
rand('state',0);

%% Load data and create train/test split
fprintf('Loading Data and setting up objective...\n');
standardize = 1;
addBias = 1;
[X,y] = loadd(data,standardize,addBias);
[n,p] = size(X);

if trainRatio ~= 1
    ind = randperm(n);
    trainNdx = ind(1:ceil(n/2));
    testNdx = ind(ceil(n/2)+1:end);
    Xtest = X(testNdx,:);
    ytest = y(testNdx);
    X = X(trainNdx,:);
    y = y(trainNdx);
    n = length(y);
    nTest = length(ytest);
end
Xt = X';
fprintf('Done\n');

%% Set up optimization problem
w = zeros(p,1);
lambda = 1/n;
t = 0.5;
M = 100;
miniBatchSize = M;
fixedSize = 80;
switch loss
    case 'logistic'
        funObj = @(w)(1/n)*LogisticLoss(w,X,y) + (lambda/2)*(w'*w);
        if trainRatio ~= 1
            funObjTest = @(w)(1/nTest)*LogisticLoss(w,Xtest,ytest);
            funObjTestErr = @(w)(1/nTest)*sum(sign(Xtest*w)~=ytest);
        else
            funObjTest = @(w)0;
            funObjTestErr = @(w)0;
        end
    case 'hsvm'
        funObj = @(w)(1/n)*HSVMLoss(w,X,y,t) + (lambda/2)*(w'*w);
        if trainRatio ~= 1
            funObjTest = @(w)(1/nTest)*HSVMLoss(w,Xtest,ytest,t);
            funObjTestErr = @(w)(1/nTest)*sum(sign(Xtest*w)~=ytest);
        else
            funObjTest = @(w)0;
            funObjTestErr = @(w)0;
        end
end

%% Initialization
switch loss
    case 'logistic'
        L = .25*max(sum(X.^2,2));
    case 'hsvm'
        L = max(sum(X.^2,2));
end
stepSize = 1/L;

%% Set up tracing of objective
randn('state',0);
rand('state',0);
fEvals = 0;
fVal = funObj(w);
fTest = funObjTest(w);
fTestErr = funObjTestErr(w);

%% Optimize

switch method(1:4)
    case 'Full'
        grow = 0;
        mixed = 0;
    case 'Grow'
        grow = 1;
        mixed = 0;
    case 'Mixe'
        grow = 1;
        mixed = 1;
end
SV = 0;
switch method(end-2:end)
    case 'SV1'
        SV = 1;
    case 'SV2'
        SV = 2;
end
        

s = 0;
k = 0;
if grow
    Bs = 1;
    alpha = 2;
else
    Bs = n;
end

if SV == 2
    passes = int32(zeros(n,1));
    skip = int32(zeros(n,1));
end

while k < maxIter*n
    s = s + 1;
    
    if Bs == n
        switch loss
            case 'logistic'
                d = -(X'*(y./(1+exp(y.*(X*w)))));
            case 'hsvm'
                if s > 1 && SV == 2
                    tau = t+ones(n,1);
                    skipInd = skip > 0;
                    evalInd = skip == 0;
                    tau(evalInd) = y(evalInd).*(X(evalInd,:)*w);
                    passed = tau > t+1;
                    passes(evalInd & ~passed) = 0;
                    passes(evalInd & passed) = passes(evalInd & passed) + 1;
                    skip(evalInd & passed & (passes >= 2)) = 2.^(passes(evalInd & passed & (passes >= 2))-2);
                    skip(skipInd) = skip(skipInd) - 1;
                    k = k - sum(skipInd);
                else
                    tau = y.*(X*w);
                end
                sig = zeros(n,1);
                sig(tau < 1-t) = -1;
                sig(abs(1-tau) < t) = -1/2/t * (1+t-tau(abs(1-tau)<t));
                d = X' * (sig.*y);
        end
        mu = (1/n)*d;
        k = k + n;
        
        % Choose number of inner iterations
        m = n;
        
        if mixed
            covered = int32(ones(n,1));
        end
    else
        d = zeros(p,1);
        perm = randperm(n);
        batch = perm(1:Bs);
        switch loss
            case 'logistic'
                d = full(-(X(batch,:)'*(y(batch)./(1+exp(y(batch).*(X(batch,:)*w))))));
            case 'hsvm'
                tau = zeros(n,1);
                tau(batch) = y(batch).*(X(batch,:)*w);
                sig = zeros(n,1);
                sig(tau <= 1-t) = -1;
                sig(abs(1-tau) <= t) = -1/2/t*(1+t-tau(abs(1-tau) <= t));
                d = full(X(batch,:)'*(y(batch).*sig(batch)));
        end
        mu = (1/Bs)*d;
        k = k + Bs;
        
        m = Bs;
        
        if mixed
            covered = int32(zeros(n,1));
            covered(batch) = 1;
        end
    end
    
    % Store value of w
    ws = w;
    ws(1) = ws(1);
    
    fEvals(end+1,1) = k;
    fVal(end+1,1) = funObj(w);
    fTest(end+1,1) = funObjTest(w);
    fTestErr(end+1,1) = funObjTestErr(w);
    fprintf('k = %d of %d, f = %e\n',k,n*maxIter,fVal(end));
    
    % Choose samples
    iVals = int32(ceil(n*rand(m,1)));
    
    % Inner loop
    increment = floor(n/5);
    for inner = 0:increment:m-1
        samples = iVals(inner+1:min(inner+increment,m));
        
        switch method
             case {'Full','Grow'}
                switch loss
                    case 'logistic'
                        SVRG_logistic(w,Xt,y,lambda,stepSize,samples,mu,ws);
                        k = k + 2*length(samples);
                    case 'hsvm'
                        evals = SVRG_hsvm(w,Xt,y,lambda,stepSize,samples,mu,ws);
                        k = k + evals;
                end
            case {'Full-SV1','Grow-SV1'}
                covered = int32(ones(n,1));
                oldZero = int32(sig==0);
                evals = SVRG_hsvm(w,Xt,y,lambda,stepSize,samples,mu,ws,covered,oldZero);
                k = k + evals;
            case {'Full-SV2','Grow-SV2'}
                oldZero = int32(sig==0);
                evals = SVRG_hsvm_skip(w,Xt,y,lambda,stepSize,samples,mu,ws,oldZero,passes,skip);
                k = k + evals;
            case {'Mixed'}
                switch loss
                    case 'logistic'
                        SVRG_logistic(w,Xt,y,lambda,stepSize,samples,mu,ws,covered);
                        k = k + length(samples) + sum(covered(samples));
                    case 'hsvm'
                        evals = SVRG_hsvm(w,Xt,y,lambda,stepSize,samples,mu,ws,covered); 
                        k = k + evals;
                end
            case {'Mixed-SV1'}
                oldZero = int32(sig==0);
                evals = SVRG_hsvm(w,Xt,y,lambda,stepSize,samples,mu,ws,covered,oldZero);
                k = k + evals;
        end
        
        fEvals(end+1,1) = k;
        fVal(end+1,1) = funObj(w);
        fTest(end+1,1) = funObjTest(w);
        fTestErr(end+1,1) = funObjTestErr(w);
        fprintf('k = %d of %d, f = %e\n',k,n*maxIter,fVal(end));
        
        if k > maxIter*n
            break;
        end
        
    end

    % Update batch size
    if grow
        Bs = Bs*alpha;
    end
    Bs = min(round(Bs),n);
end
            
%% Store Result
result.n = n;
result.fVal = fVal;
result.fEvals = fEvals;
result.fTest = fTest;
result.fTestErr = fTestErr;
end
