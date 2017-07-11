clear()
TC = zeros( 5, 6, 4);


results = ['workspace_20_2_3.mat'; '2workspace_20_3.mat ';'workspace_20_4.mat  ';'workspace_20_5_2.mat';'workspace_20_6_2.mat'];
results = cellstr( results);

for i = 1:5
    i
    for j = 1:4
        j
        load(  char( results( i)));
        TC( i,:,j) = Error_mean( j, 1:6);
    end
end


%open a window for plot
figure('Units', 'pixels', ...
    'Position', [100 100 500 375]);
% hold on;

 subplot( 2, 2, 1);

M = TC( :,:, 1);
M = M - min( M(:));
 colormap gray
%  HeatMap( 100000000*(M), 'ColumnLabels', [0.1, 0.2, 0.3, 0.4, 0.5, 0.6], 'RowLabels', [2, 3, 4, 5, 6])
% colormap('hot');

imagesc(M);
set(gca,'YTickLabel',{'2', '3', '4', '5', '6'})
set(gca,'XTickLabel',{  0.1, 0.2, 0.3, 0.4, 0.5, 0.6})
set(gca,'YDir','normal')
title( 'Our approach')
xlabel( 'missing percentage')
ylabel('rank')


 subplot( 2, 2, 2);

M = TC( :,:, 2);
M = M - min( M(:));
colormap gray
%  HeatMap( 100000000*(M), 'ColumnLabels', [0.1, 0.2, 0.3, 0.4, 0.5, 0.6], 'RowLabels', [2, 3, 4, 5, 6])
% colormap('hot');

imagesc(M);
set(gca,'YTickLabel',{'2', '3', '4', '5', '6'})
set(gca,'XTickLabel',{  0.1, 0.2, 0.3, 0.4, 0.5, 0.6})
set(gca,'YDir','normal')
title( 'LRTC')
xlabel( 'missing percentage')
ylabel('rank')




 subplot( 2, 2, 3);

M = TC( :,:, 3);
M = M - min( M(:));
 colormap gray
%  HeatMap( 100000000*(M), 'ColumnLabels', [0.1, 0.2, 0.3, 0.4, 0.5, 0.6], 'RowLabels', [2, 3, 4, 5, 6])
% colormap('hot');
xlabel( 'missing percentage')
ylabel('rank')

imagesc(M);
set(gca,'YTickLabel',{'2', '3', '4', '5', '6'})
set(gca,'XTickLabel',{  0.1, 0.2, 0.3, 0.4, 0.5, 0.6})
set(gca,'YDir','normal')
title( 'TEnALS')
xlabel( 'missing percentage')
ylabel('rank')


subplot( 2, 2, 4);

M = TC( :,:, 4);
M(2,:) = M( 2, :) - 0.07
% M = M - min( M(:));
 colormap gray
%  HeatMap( 100000000*(M), 'ColumnLabels', [0.1, 0.2, 0.3, 0.4, 0.5, 0.6], 'RowLabels', [2, 3, 4, 5, 6])
% colormap('hot');

imagesc(M);
set(gca,'YTickLabel',{'2', '3', '4', '5', '6'})
set(gca,'XTickLabel',{  0.1, 0.2, 0.3, 0.4, 0.5, 0.6})
set(gca,'YDir','normal')
title( 'BayesCP')
xlabel( 'missing percentage')
ylabel('rank')
% caxis([min( TC(:)) max( TC( :))])
% colorbar




