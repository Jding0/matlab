#include <math.h>
#include "mex.h"

/*
SVRG_logistic(w,Xt,y,lambda,alpha,iVals,d,wOld,covered);
% w(p,1) - updated in place
% Xt(p,n) - real, can be sparse
% y(n,1) - {-1,1}
% lambda - scalar regularization param
% stepSize - scalar constant step size
% iVals(maxIter,1) - sequence of examples to choose
%
% The below are updated in place and are needed for restarting the algorithm
% d(p,1) - approximation of full gradient
% wOld(p,1) - parameter vector used to make approximation of full gradient
% covered(n,1) - whether the example was used to make the approximation of full gradient
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    /* Variables */
    int k,nSamples,maxIter,sparse=0,*iVals,*lastVisited,trackSum=0;
    long i,j,nVars;
    int *oldZero;
    int *passes,*skip,passed;
    
    mwIndex *jc,*ir;
    
    double *w, *Xt, *y, lambda, alpha, innerProd, sig,sigOld,c=1,*wOld,*d,*cumSum;
    double tau,epsilon = 0.5, *evals;
    
    if (nrhs != 11)
        mexErrMsgTxt("Function needs at least eight arguments: {w,Xt,y,lambda,alpha,iVals,d,wOld,oldZero,passes,skip}");
    
    /* Input */
    
    w = mxGetPr(prhs[0]);
    Xt = mxGetPr(prhs[1]);
    y = mxGetPr(prhs[2]);
    lambda = mxGetScalar(prhs[3]);
    alpha = mxGetScalar(prhs[4]);
    iVals = (int*)mxGetPr(prhs[5]);
    if (!mxIsClass(prhs[5],"int32"))
        mexErrMsgTxt("iVals must be int32");
    d = mxGetPr(prhs[6]);
    wOld = mxGetPr(prhs[7]);
        oldZero = (int*)mxGetPr(prhs[8]);
        passes = (int*)mxGetPr(prhs[9]);
        skip = (int*)mxGetPr(prhs[10]);
        
    /* Compute Sizes */
    nVars = mxGetM(prhs[1]);
    nSamples = mxGetN(prhs[1]);
    maxIter = mxGetM(prhs[5]);
        
    if (nVars != mxGetM(prhs[0]))
        mexErrMsgTxt("w and Xt must have the same number of rows");
    if (nSamples != mxGetM(prhs[2]))
        mexErrMsgTxt("number of columns of Xt must be the same as the number of rows in y");
    if (nVars != mxGetM(prhs[6]))
        mexErrMsgTxt("w and d must have the same number of rows");
    if (nVars != mxGetM(prhs[7]))
        mexErrMsgTxt("w and wOld must have the same number of rows");
        
    if (mxIsSparse(prhs[1])) {
        sparse = 1;
        jc = mxGetJc(prhs[1]);
        ir = mxGetIr(prhs[1]);
    }
    
    if (sparse && alpha*lambda==1)
        mexErrMsgTxt("Sorry, I don't like it when Xt is sparse and alpha*lambda=1\n");
    
    /* Output (returns number of inner products) */
    if (nlhs > 0) {
        plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
        evals = mxGetPr(plhs[0]);
    }
    
    /* Allocate memory needed for lazy updates */
    if (sparse) {
        lastVisited = mxCalloc(nVars,sizeof(int));
        cumSum = mxCalloc(maxIter,sizeof(double));
        
        /*for(j=0;j<nVars;j++)
            lastVisited[j] = -1;*/
    }
    
    for(k=0;k<maxIter;k++)
    {
        /* Select next training example */
        i = iVals[k]-1;
        
        /* Compute current values of needed parameters */
        if (sparse && k > 0) {
            for(j=jc[i];j<jc[i+1];j++) {
                if (lastVisited[ir[j]]==0) {
                    w[ir[j]] -= d[ir[j]]*cumSum[k-1];
                }
                else {
                    w[ir[j]] -= d[ir[j]]*(cumSum[k-1]-cumSum[lastVisited[ir[j]]-1]);
                }
                lastVisited[ir[j]] = k;
            }
        }
        
        /* Compute derivative of loss */
        if (skip[i] > 0) {
            sig = 0;
            skip[i]--;
        }
        else {
            innerProd = 0;
            if (sparse) {
                for(j=jc[i];j<jc[i+1];j++)
                    innerProd += w[ir[j]]*Xt[j];
                innerProd *= c;
            }
            else {
                for(j=0;j<nVars;j++)
                    innerProd += w[j]*Xt[j + nVars*i];
            }
            tau = y[i]*innerProd;
            if (tau >= 1 + epsilon) {
                sig = 0;
                passes[i]++;
                if(passes[i] > 2)
                    skip[i] = pow(2,passes[i]-2);
            }
            else if (tau <= 1 - epsilon) {
                sig = -y[i];
                passes[i] = 0;
            }
            else {
                sig = -y[i]*(1+epsilon-tau)/(2.0*epsilon);
                passes[i] = 0;
            }
            evals[0] += 1;
        }
        
        
        if (oldZero[i])
            sigOld = 0;
        else {
            innerProd = 0;
            if (sparse) {
                for(j=jc[i];j<jc[i+1];j++)
                    innerProd += wOld[ir[j]]*Xt[j];
            }
            else
            {
                for(j=0;j<nVars;j++)
                    innerProd += wOld[j]*Xt[j + nVars*i];
            }
            tau = y[i]*innerProd;
            if (tau >= 1 + epsilon)
                sigOld = 0;
            else if (tau <= 1 - epsilon)
                sigOld = -y[i];
            else
                sigOld = -y[i]*(1+epsilon-tau)/(2.0*epsilon);
            evals[0] += 1;
        }

        /* Update parameters */
        if (sparse)
        {
            c *= 1-alpha*lambda;
            
            if (k==0)
                cumSum[0] = alpha/c;
            else
                cumSum[k] = cumSum[k-1] + alpha/c;
            for(j=jc[i];j<jc[i+1];j++)
                w[ir[j]] -= alpha*(Xt[j]*(sig-sigOld))/c;
        }
        else {
            for(j=0;j<nVars;j++) {
                w[j] *= 1-alpha*lambda;
            }
            
            for(j=0;j<nVars;j++)
                w[j] -= alpha*(Xt[j + nVars*i]*(sig-sigOld) + d[j]);
        }

    }
    
    if (sparse) {
        for(j=0;j<nVars;j++) {
            if (lastVisited[j]==0) {
                w[j] -= d[j]*cumSum[maxIter-1];
            }
            else
            {
                w[j] -= d[j]*(cumSum[maxIter-1]-cumSum[lastVisited[j]-1]);
            }
        }
        
        for(j=0;j<nVars;j++)
            w[j] *= c;
        mxFree(lastVisited);
        mxFree(cumSum);
    }
    
}
