%function  demo()
% demonstration file for SGDLibrary.
%
% This file illustrates how to use this library in case of linear
% regression problem. This demonstrates SGD and SVRG algorithms.
%
% This file is part of SGDLibrary.
%
% Created by H.Kasai on Oct. 24, 2016
% Modified by H.Kasai on Nov. 03, 2016


    clc;
    clear;
    close all;
    rng;

    %% generate synthetic data        
    % set number of dimensions
    d = 30;
    % set number of samples    
    n = 10000;
    % generate data
    data = logistic_regression_data_generator(n, d);
        
    
    %% define problem definitions
    problem = logistic_regression(data.x_train, data.y_train, data.x_test, data.y_test); 
    
    
%     %% perform algorithms SQN and Parallel SQN
    options.w_init = data.w_init;  
    options.max_epoch = 30;
    options.step_init = 0.01; 
    options.verbose = true;
%     
%     %setting 1
%     options.thread_num = 1;
%     options.batch_size = 10;
%     options.batch_hess_size = 100;
%     
%     [w_Parallel_slbfgs_1, info_Parallel_slbfgs_1] = Parallel_slbfgs(problem, options);
%     
%      %setting 2
%     options.thread_num = 10;
%     options.batch_size = 10;
%     options.batch_hess_size = 100;
%     
%     [w_Parallel_slbfgs_2, info_Parallel_slbfgs_2] = Parallel_slbfgs(problem, options);
%     
% %     
%      %setting 3
%     options.thread_num = 10;
%     options.batch_size = 10;
%     options.batch_hess_size = 50;
%     
%     [w_Parallel_slbfgs_3, info_Parallel_slbfgs_3] = Parallel_slbfgs(problem, options);
%     
%      %setting 4
%     options.thread_num = 10;
%     options.batch_size = 10;
%     options.batch_hess_size = 1000;
%     
%     [w_Parallel_slbfgs_4, info_Parallel_slbfgs_4] = Parallel_slbfgs(problem, options);
%     
%      %setting 5
%     options.thread_num = 10;
%     options.batch_size = 100;
%     options.batch_hess_size = 1000;
%     
%     [w_Parallel_slbfgs_5, info_Parallel_slbfgs_5] = Parallel_slbfgs(problem, options);
%     
%     display_graph('iter','cost', {'t num 1 b g 10 b h 100', 't num 10 b g 10 b h 100', 't num 10 b g 10 b h 50', 't num 10 b g 10 b h 1000', 't num 10 b g 100 b h 1000'}, {w_Parallel_slbfgs_1,w_Parallel_slbfgs_2, w_Parallel_slbfgs_3, w_Parallel_slbfgs_4, w_Parallel_slbfgs_5}, {info_Parallel_slbfgs_1,info_Parallel_slbfgs_2,  info_Parallel_slbfgs_3, info_Parallel_slbfgs_4, info_Parallel_slbfgs_5});
% 
%     display_graph('iter','optimality_gap', {'t num 1 b g 10 b h 100', 't num 10 b g 10 b h 100', 't num 10 b g 10 b h 50', 't num 10 b g 10 b h 1000', 't num 10 b g 100 b h 1000'}, {w_Parallel_slbfgs_1,w_Parallel_slbfgs_2,  w_Parallel_slbfgs_3, w_Parallel_slbfgs_4, w_Parallel_slbfgs_5}, {info_Parallel_slbfgs_1, info_Parallel_slbfgs_2, info_Parallel_slbfgs_3, info_Parallel_slbfgs_4, info_Parallel_slbfgs_5});

    %Parallel LBFGS/SQN
    options.thread_num = 10;
    options.batch_size = 10;
    options.batch_hess_size = 100;
    
    [w_Parallel_slbfgs, info_Parallel_slbfgs] = Parallel_slbfgs(problem, options);
    
    
    %LBFGS/SQN
    options.batch_size = 10;
    options.batch_hess_size = 100;
    [w_slbfgs, info_slbfgs] = slbfgs(problem, options); 
    %SVRG
    options.batch_size = 1;
    [w_svrg, info_svrg] = svrg(problem, options);
    
    %SGD
    
    %Parallel SVRG-LBFGS/SQN
    options.thread_num = 10;
    options.batch_size = 10;
    options.batch_hess_size = 100;
    options.sub_mode = 'SVRG-LBFGS';
    [w_Parallel_svrg_slbfgs, info_Parallel_svrg_slbfgs] = Parallel_slbfgs(problem, options);
    
    %SVRG-LBFGS/SQN
    options.thread_num = 1;
    options.batch_size = 10;
    options.batch_hess_size = 100;
    options.sub_mode = 'SVRG-LBFGS';
    [w_svrg_slbfgs, info_svrg_slbfgs] = Parallel_slbfgs(problem, options);
    
    
    %Parallel SVRG
    options.batch_size = 10; %kind of MapReduce paralel for SGD
    [w_Parallel_svrg, info_Parallel_svrg] = svrg(problem, options);
    
%     %LBFGS
    options.max_iter = 30;
    [w_lbfgs, info_lbfgs] = lbfgs(problem, options);
    %% display cost/optimality gap vs number of gradient evaluations
    display_graph('iter','cost', {'Parallel LBFGS/SQN', 'LBFGS/SQN', 'SVRG', 'Parallel SVRG-LBFGS','SVRG-LBFGS', 'Minibatch/Parallel SVRG', 'LBFGS'}, {w_Parallel_slbfgs, w_slbfgs, w_svrg, w_Parallel_svrg_slbfgs,w_svrg_slbfgs,  w_Parallel_svrg, w_lbfgs}, {info_Parallel_slbfgs, info_slbfgs, info_svrg, info_Parallel_svrg_slbfgs, info_svrg_slbfgs, info_Parallel_svrg, info_lbfgs});
    display_graph('iter','optimality_gap', {'Parallel LBFGS/SQN', 'LBFGS/SQN', 'SVRG', 'Parallel SVRG-LBFGS','SVRG-LBFGS', 'Minibatch/Parallel SVRG', 'LBFGS'}, {w_Parallel_slbfgs, w_slbfgs, w_svrg, w_Parallel_svrg_slbfgs,w_svrg_slbfgs,  w_Parallel_svrg, w_lbfgs}, {info_Parallel_slbfgs, info_slbfgs, info_svrg, info_Parallel_svrg_slbfgs, info_svrg_slbfgs, info_Parallel_svrg, info_lbfgs});

% %end
% 

