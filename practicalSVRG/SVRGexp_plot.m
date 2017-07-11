function SVRGexp_plot(dataSet,experimentName,trainRatio,methods,maxIter)
searchForAll = 1;
doTest = 1;

if strcmp(experimentName,'mini')
    loss = 'logistic';
else
    loss = experimentName;
end

% Get ground truth
minVal = runExp(@SVRGgetGroundTruth,dataSet,loss,trainRatio)

% Run methods
fVal = cell(0,1);
fEval = cell(0,1);
fTest = cell(0,1);
names = cell(0,1);
colors = zeros(0,3);
randColors = rand(20,3);
markers = cell(0,1);
markerSpacing = zeros(0,2);

lineStyles = [];
k = 0;
minTest = inf;
minerr =  inf;
[colors] = getColorsRGB();
for m = 1:length(methods)
    name = methods{m};
    
    % Search for the optimal step size
    if 0%strcmp(name,'Mixed')
        minStep = -6;
        %minStep = -10;
        maxStep = 1;
        steps = minStep:maxStep;
        bestVal = inf;
        for step = steps
            stepSize = 10^step;
            if strcmp(experimentName,'mini')
                result = runExp(@SVRGexp_batch,dataSet,loss,trainRatio,name,maxIter,stepSize);
            else
                result = runExp(@SVRGexp_single,dataSet,loss,trainRatio,name,maxIter,stepSize);
            end
            if ~isLegal(result.fVal(end))
                break;
            end
            
            if min(result.fTest) < minTest
                minTest = min(result.fTest);
            end
            if min(result.fTestErr) < minerr
                minerr = min(result.fTestErr);
            end
            
            if min(result.fVal) <= bestVal
                bestVal = min(result.fVal);
                bestStep = step;
                bestStepSize = stepSize;
            else
                break;
            end
        end
        bestStepSize
        if bestStep == steps(1)
            fprintf('%s took minStep on %s\n',name,dataSet);
            %pause
        elseif bestStep == steps(end)
            fprintf('%s took maxStep on %s\n',name,dataSet);
           % pause
        end
        stepSize = bestStepSize;
    else
        stepSize = 0;
    end
    
    % Load best step-size
    if strcmp(experimentName,'mini')
        result = runExp(@SVRGexp_batch,dataSet,loss,trainRatio,name,maxIter,stepSize);
    else
        result = runExp(@SVRGexp_single,dataSet,loss,trainRatio,name,maxIter,stepSize);
    end
    k = k + 1;
    fVals{k,1} = result.fVal-minVal;
    fEvals{k,1} = result.fEvals/result.n;
    fTests{k,1} = result.fTest;
    fTestErrs{k,1} = result.fTestErr;
    
    %%%
    switch name
        %         switch method_ALL{:}
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         case 'FullC'
%             names{end+1,1} = 'SVRG';
%             markers{end+1,1} = 'o';
%             %                 names{end+1,1} = 'Full';
%             %markers{end+1,1} = 'o';
%             %                 colors(end+1,:) = [0 0 1];
%             lineStyles{end+1,1} = '-';
%             %             markerSpacing(end+1,:) = [20 1];
%             markerSpacing(end+1,:) = [ceil(length(fVals{1})/4) 1]
        case 'Grow1C'
            names{end+1,1} = 'Grow';
            markers{end+1,1} = 's';
            %                 names{end+1,1} = 'Doub';
            %markers{end+1,1} = '>';
            %                 colors(end+1,:) = [0 1 0];
            lineStyles{end+1,1} = '-';
            %             markerSpacing(end+1,:) = [20 2];
            markerSpacing(end+1,:) = [ceil(length(fVals{2})/4) 2]
        case 'MixedS2'
            names{end+1,1} = 'Mixed';
            markers{end+1,1} = '^';
            %                 names{end+1,1} = 'Doub-Mix';
            %markers{end+1,1} = 's';
            %                 colors(end+1,:) = [1 0 0];
            lineStyles{end+1,1} = '-';
            %             markerSpacing(end+1,:) = [20 3];
            markerSpacing(end+1,:) = [ceil(length(fVals{3})/4) 3]
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'FullC'
            names{end+1,1} = 'SVRG';
            markers{end+1,1} = 'o';
            %                 names{end+1,1} = 'Full';
            %markers{end+1,1} = 'o';
            %                 colors(end+1,:) = [0 0 1];
            lineStyles{end+1,1} = '-';
            %             markerSpacing(end+1,:) = [20 1];
            markerSpacing(end+1,:) = [ceil(length(fVals{1})/4) 1]
        case 'FullSVC'
            names{end+1,1} = 'SVRG-SV1';
            markers{end+1,1} = 's';
            %                 names{end+1,1} = 'Doub';
            %markers{end+1,1} = '>';
            %                 colors(end+1,:) = [0 1 0];
            lineStyles{end+1,1} = '-';
            %             markerSpacing(end+1,:) = [20 2];
            markerSpacing(end+1,:) = [ceil(length(fVals{2})/4) 2]
        case 'FullSV3C'
            names{end+1,1} = 'SVRG-SV2';
            markers{end+1,1} = '^';
            %                 names{end+1,1} = 'Doub-Mix';
            %markers{end+1,1} = 's';
            %                 colors(end+1,:) = [1 0 0];
            lineStyles{end+1,1} = '-';
            %             markerSpacing(end+1,:) = [20 3];
            markerSpacing(end+1,:) = [ceil(length(fVals{3})/4) 3]
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'miniUC'
            names{end+1,1} = 'Uniform';
            markers{end+1,1} = 'o';
            %                 names{end+1,1} = 'Full';
            %markers{end+1,1} = 'o';
            %                 colors(end+1,:) = [0 0 1];
            lineStyles{end+1,1} = '-';
            %             markerSpacing(end+1,:) = [20 1];
            markerSpacing(end+1,:) = [ceil(length(fVals{1})/4) 1]
        case 'miniLC'
            names{end+1,1} = 'Lipschitz';
            markers{end+1,1} = 's';
            %                 names{end+1,1} = 'Doub';
            %markers{end+1,1} = '>';
            %                 colors(end+1,:) = [0 1 0];
            lineStyles{end+1,1} = '-';
            %             markerSpacing(end+1,:) = [20 2];
            markerSpacing(end+1,:) = [ceil(length(fVals{2})/4) 2]
        case 'miniFC'
            names{end+1,1} = 'Lipschitz+';
            markers{end+1,1} = '^';
            %                 names{end+1,1} = 'Doub-Mix';
            %markers{end+1,1} = 's';
            %                 colors(end+1,:) = [1 0 0];
            lineStyles{end+1,1} = '-';
            %             markerSpacing(end+1,:) = [20 3];
            markerSpacing(end+1,:) = [ceil(length(fVals{3})/4) 3]
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'SV-SVRGC-Full'
            names{end+1,1} = 'SVRG-SV1';
            %markers{end+1,1} = '^';
            %                 colors(end+1,:) = [1 .5 0];
            lineStyles{end+1,1} = '-';
        case 'V2-SVRGC-Full'
            names{end+1,1} = 'SVRG-SV2';
            %markers{end+1,1} = '^';
            %                 colors(end+1,:) = [1 1 0];
            lineStyles{end+1,1} = '-';
            
        case 'SV-SVRGC-FSB'
            names{end+1,1} = 'Grow-SV1';
            %markers{end+1,1} = '^';
            %                 colors(end+1,:) = [0 1 1];
            lineStyles{end+1,1} = '-';
        case 'V2-SVRGC-FSB'
            names{end+1,1} = 'Grow-SV2';
            %markers{end+1,1} = '^';
            %                 colors(end+1,:) = [1 0 1];
            lineStyles{end+1,1} = '-';
            
        case 'SV-SVRG1C-FSB'
            names{end+1,1} = 'Mixed-SV1';
            %markers{end+1,1} = '^';
            %                 colors(end+1,:) = [1 1 1];
            lineStyles{end,1} = '-';
        case 'V2-SVRG1C-FSB'
            names{end+1,1} = 'Mixed-SV2';
            %markers{end+1,1} = '^';
            %                 colors(end+1,:) = [0 0 0.5];
            lineStyles{end,1} = '-';
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'SVRG1C-BrB'
            names{end+1,1} = 'Vari';
            %markers{end+1,1} = 'v';
            colors(end+1,:) = [1 0 1];
            lineStyles{end,1} = '-';
        case 'SVRG1C-AB'
            names{end+1,1} = 'Ang';
            %markers{end+1,1} = '^';
            colors(end+1,:) = [1 .5 0];
            lineStyles{end,1} = '-';
        case 'SVRG1C-CvB'
            names{end+1,1} = 'CV';
            %markers{end+1,1} = 'p';
            colors(end+1,:) = [0 1 1];
            lineStyles{end,1} = '-';
        otherwise
            %         names{end+1,1} = strcat(method{:},'-',mMethod,num2str([alph, mFactor]));
            names{end+1,1} = name;
            %                 names{end+1,1} = sprintf('%s (%.1e)',method{:},stepSize);
            markers{end+1,1} = [];
            %                                 colors(end+1,:) = randColors(m,:);
    end
end

% % % options.logScale = 2;
% % % options.legend = methods;
% % % options.labelLines = 1;
% % % figure
% % % prettyPlot(fEvals,fVals,options);
% % % print('-dpdf',sprintf('plots/SVRG_%s_%s.pdf',loss,dataSet));
% % %
% % % if doTest
% % % figure
% % % options.logScale = 0;
% % % options.labelLines = 0;
% % % prettyPlot(fEvals,fTests,options);
% % % ylim([minTest mean([fTests{1}(1),fTests{1}(3)])]);

if strcmp(dataSet(end-3:end),'.mat')
    dataSet(end-3:end) = [];
end

options.legendLoc = 'NorthEast';
options.logScale = 2;
options.colors = colors;
options.lineStyles = lineStyles;
options.markers = markers;
options.markerSize = 8;
% options.markerSize = 12;
%options.markerSpacing = markerSpacing;
options.legendStr = names;
options.legend = names;
options.ylabel = 'Objective minus Optimum';
options.xlabel = 'Effective Passes';
% if ~strcmp(name,'size')
if 1
    options.labelLines = 0;
    %         options.labelLines = 1;
    options.labelRotate = 1;
    options.ylimits = [-inf 1.01];
else
    options.ylimits = [-inf 1.5];
end
options.xlimits = [0 maxIter];

figure;
prettyPlot(fEvals,fVals,options);
% ylim([min(fTestErrs{1}(1))-0.1 max(fTestErrs{1}(1))+0.1]);

%ylim([0 1.1]);
%iptsetpref('ImshowBorder','tight');
% if nargin < 10 || isempty(name)
if 0
        print('-dpdf',sprintf('plots/mini_train_%s_%s.pdf',loss,dataSet));
%     print('-dpdf',sprintf('plots/SV_train_%s_%s.pdf',loss,dataSet));
else
    print('-dpdf',sprintf('plots/%s_%s_%s.pdf',experimentName,loss,dataSet));
end
%print('-depsc',sprintf('plots/train_%s_%s.eps',loss,dataSet));

if trainRatio ~= 1 && doTest
    %     figure;
    %     options.logScale = 0;
    %     options.ylabel = 'Test Logistic Loss';
    %     options.ylimits = [];
    %     prettyPlot(fEvals,fTests,options);
    %     xlim([0 maxIter]);
    %     yl = ylim;
    %         switch dataSet
    %             case 'quantum'
    %                 ylim([min(fTestErrs{1}(1))-0.1 max(fTestErrs{1}(1))+0.1]);
    %             case 'protein'
    % %                 ylim([minerr fTestErrs{1}(1)]);
    %             case 'sido'
    % %                 ylim([minerr fTestErrs{1}(1)]);
    %             case 'rcv1'
    % %                 ylim([minerr fTestErrs{1}(1)]);
    %             case 'covertype'
    % %                 ylim([minerr fTestErrs{1}(1)]);
    %             case 'news'
    % %                 ylim([minerr fTestErrs{1}(1)]);
    %             case 'spam'
    % %                 ylim([minerr fTestErrs{1}(1)]);
    %             case 'rcv1Full'
    % %                 ylim([minerr fTestErrs{1}(1)]);
    %             case 'alpha'
    % %                 ylim([minerr fTestErrs{1}(1)]);
    %         end
    %     %yl = ylim;
    %     %iptsetpref('ImshowBorder','tight');
    %     print('-dpdf',sprintf('plots/%s_%s_%s_testLoss.pdf',name,loss,dataSet));
    %     %print('-depsc',sprintf('plots/testLoss_%s_%s.eps',loss,dataSet));
    
    figure;
    options.logScale = 0;
    options.ylabel = 'Test Error';
    prettyPlot(fEvals,fTestErrs,options);
    xlim([0 maxIter]);
    %     switch dataSet
    %         case 'quantum'
    %             ylim([.28 .4]);
    %         case 'protein'
    %             ylim([0 .01]);
    %         case 'sido'
    %             ylim([.03 .04]);
    %         case 'rcv1'
    %             ylim([.04 .05]);
    %         case 'covertype'
    %             ylim([.24 .28]);
    %     end
    %yl = ylim;
    minY = min(fTestErrs{end});
    ylim([max(0,minY-.01) minY+0.05]);
    
    %iptsetpref('ImshowBorder','tight');
        print('-dpdf',sprintf('plots/%s_testErr_%s_%s.pdf',experimentName,loss,dataSet));
%     print('-dpdf',sprintf('plots/SV_testErr_%s_%s.pdf',loss,dataSet));
    %     print('-dpdf',sprintf('plots/%s_%s_%s_testErr.pdf',name,loss,dataSet));
    
    %print('-depsc',sprintf('plots/testError_%s_%s.eps',loss,dataSet));
end

end
