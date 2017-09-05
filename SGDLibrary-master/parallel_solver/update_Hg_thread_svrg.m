function  w_thread_s = update_Hg_thread_svrg(problem, w, step,j,batch_size, w0, full_grad, s_array, y_array, epoch, perm_idx )
               
    % calculate gradient
    start_index = (j-1) * batch_size + 1;
    indice_j = perm_idx(start_index:start_index+batch_size-1);
    grad = problem.grad(w, indice_j);

    % calculate variance reduced gradient
    grad_w0 = problem.grad(w0,indice_j);
    grad = full_grad + grad - grad_w0;    


    if epoch > 0              
        % perform LBFGS two loop recursion
        Hg = lbfgs_two_loop_recursion(grad, s_array, y_array);
        % update w            
        w_thread_s = w + (step*Hg);  
    else
        w_thread_s = w - (step*grad); 
    end