function [X,y] = loadd(datafile,standardize,addBias)
% [X,y] = loadd(datafile,standardize,addBias)

if nargin < 2
    standardize = 0;
    if nargin < 3
        addBias = 0;
    end
end

%dataDir = '/meleze/data0/schmidtm';
dataDir = pwd;
switch datafile
    case 'sido'
        load(sprintf('%s/data/classificationBinary/sido0_train.mat',dataDir));
        y = load(sprintf('%s/data/classificationBinary/sido0_train.targets',dataDir));
    case 'thrombin'
        [y,X] = libsvmread(sprintf('%s/data/classificationBinary/thrombin.txt',pwd));
    case 'spam'
        load(sprintf('%s/data/classificationBinary/trec2005.mat',dataDir));
        X = A';
        clear A
        y(y==0) = -1;
    case 'rcv1'
        [y,X] = libsvmread(sprintf('%s/data/classificationBinary/rcv1_train.binary',dataDir));
    case 'rcv1Full'
        load(sprintf('%s/data/classificationBinary/rcv1.mat',dataDir));
        X = [xTrain;xTest];
        y = [yTrain;yTest];
    case 'news'
        %[y,X] = libsvmread(sprintf('%s/data/classificationBinary/news20.binary',dataDir));
        load('news.mat')
    case 'covertype'
        [y,X] = libsvmread(sprintf('%s/data/classificationBinary/covtype.libsvm.binary',dataDir));
        y(y==2) = -1;
        if standardize
            X = standardizeCols(full(X));
        end
    case 'alpha'
        load(sprintf('%s/data/classificationBinary/alpha.mat',dataDir));
        if standardize
            X = standardizeCols(X);
        end
    case 'beta'
        load(sprintf('%s/data/classificationBinary/beta.mat',dataDir));
        if standardize
            X = standardizeCols(X);
        end
    case 'gamma'
        load(sprintf('%s/data/classificationBinary/gamma.mat',dataDir));
        if standardize
            X = standardizeCols(X);
        end
    case 'delta'
        load(sprintf('%s/data/classificationBinary/delta.mat',dataDir));
        if standardize
            X = standardizeCols(X);
        end
    case 'webspam'
        load(sprintf('%s/data/classificationBinary/webpsam.mat',dataDir));
    case 'protein'
        X = load(sprintf('%s/data/classificationBinary/bio_train.dat',pwd));
        y = X(:,3);
        y(y==0) = -1;
        if standardize
            X = standardizeCols(X(:,4:end));
        else
            X = X(:,4:end);
        end
    case 'quantum'
        X = load(sprintf('%s/data/classificationBinary/phy_train.dat',pwd));
        y = X(:,2);
        y(y==0) = -1;
        X(X==999) = 0;
        X(X==9999) = 0;
        if standardize
            X = standardizeCols(X(:,3:end));
        else
            X = X(:,3:end);
        end
    case 'real-sim'
        [y,X] = libsvmread(sprintf('%s/data/classificationBinary/real-sim.svml',pwd));
    otherwise
        if strfind(datafile,'.mat')
            %fprintf('matfile\n');
            load(datafile);
        else
            %fprintf('datafile\n');
            X = load(datafile);
        end
        y = full(X(:,end));
        y(y==2) = -1;
        y(y==0) = -1;
        if standardize
            X = standardizeCols(X(:,1:end-1));
        end
end
if addBias
    X = [ones(size(X,1),1) X];
end