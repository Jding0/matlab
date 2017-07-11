

method = [ 1, 2, 3, 4];
dump_percent = [ 0.1:0.1:0.60];
linestyle = [':', '--', '-.','-']; 
marker = ['+', 'o',  'x','.'];
color = ['r', 'g', 'b', 'k'];

%  data = csvread( 'F:/Users/gul15103/Desktop/hornet_result/experimentWithoOutProduct100/experiment1/relativeError.csv', 0, 0);
% data = csvread( 'F:/Projects/Jin_Paper_experiment/hornet_result/experiment1/relativeError.csv', 0, 0);

 

%open a window for plot
figure('Units', 'pixels', ...
    'Position', [100 100 500 375]);
hold on;

subplot( 2, 2, 1)
ylim([0, 0.26])
xlim([0.05, dump_percent( length( dump_percent))+0.025])


for i = 1:size( method, 2)%for method
    ErrorBar = zeros( size( dump_percent, 2), 2);

    for j = 1:size( dump_percent, 2)%for dump_percent
        ErrorBar( j, 1) = Error_mean( i, j);
        ErrorBar( j, 2) = Error_var( i, j );

%         ErrorBar( j, 1) = mean( data( data( : , 2) == method( i ), j + 2 ));
%         if i ==3 || i == 4
%             ErrorBar( j, 2) = 0.02;
%         else
%             ErrorBar( j, 2) = sqrt( var( data( data( : , 2) == method( i), j + 2 )));
%         end
        
    end
    
    %ErrorBar

    hE(i) = errorbar(  dump_percent, ErrorBar( :, 1), ErrorBar( :, 2));
    set( hE(i),...
      'LineStyle'       , linestyle( i)      , ...
      'Marker'          , marker(i)        , ...
      'Color'           , color(i)  );
  hold on;

end

hTitle  = title ('Synthetic Experiment IV');
hXLabel = xlabel('Missing percentage'                     );
hYLabel = ylabel('RMSE'                      );


hLegend = legend( ...
  [hE(1), hE(2), hE(3), hE(4)], ...
  'Our approach' , ...
  'LRTC'      , ...
  'TEnALS'       , ...
  'BayesCP'  ,...
  'location', 'NorthWest');

