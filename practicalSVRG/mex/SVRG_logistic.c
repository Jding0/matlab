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
    int k,nSamples,maxIter,sparse=0,*iVals,*covered,*lastVisited,doSingles=0,trackSum=0;
    long i,j,nVars;
    
    mwIndex *jc,*ir;
    
    double *w, *Xt, *y, lambda, alpha, innerProd, sig,sigOld,c=1,*wOld,*d,*cumSum,*gSum;
    
    if (nrhs < 8)
        mexErrMsgTxt("Function needs nine arguments: {w,Xt,y,lambda,alpha,iVals,d,wOld[,covered]}");
    
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
    if (nrhs == 9) {
        covered = (int*)mxGetPr(prhs[8]);
        doSingles = 1;
    }
        
    /* Compute Sizes */
    nVars = mxGetM(prhs[1]);
    nSamples = mxGetN(prhs[1]);
    maxIter = mxGetM(prhs[5]);
    
    /* Output (if you want to track sum of gradients) */
    if (nlhs > 0) {
        trackSum = 1;
        plhs[0] = mxCreateDoubleMatrix(nVars, 1, mxREAL);
        gSum = mxGetPr(plhs[0]);
    }
    
    if (nVars != mxGetM(prhs[0]))
        mexErrMsgTxt("w and Xt must have the same number of rows");
    if (nSamples != mxGetM(prhs[2]))
        mexErrMsgTxt("number of columns of Xt must be the same as the number of rows in y");
    if (nVars != mxGetM(prhs[6]))
        mexErrMsgTxt("w and d must have the same number of rows");
    if (nVars != mxGetM(prhs[7]))
        mexErrMsgTxt("w and wOld must have the same number of rows");
    if (nrhs == 9) {
        if (nSamples != mxGetM(prhs[8]))
            mexErrMsgTxt("covered and y must hvae the same number of rows");
    }
    
    if (mxIsSparse(prhs[1])) {
        sparse = 1;
        jc = mxGetJc(prhs[1]);
        ir = mxGetIr(prhs[1]);
    }
    
    if (sparse && alpha*lambda==1)
        mexErrMsgTxt("Sorry, I don't like it when Xt is sparse and alpha*lambda=1\n");
    
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
        sig = -y[i]/(1+exp(y[i]*innerProd));            
        
        if (!doSingles || covered[i]==1) {
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
            sigOld = -y[i]/(1+exp(y[i]*innerProd));
        }
        
        /* Update parameters */
        if (sparse)
        {
            c *= 1-alpha*lambda;
            
            if (doSingles && covered[i] == 0) {
                if (k==0)
                    cumSum[0] = 0;
                else
                    cumSum[k] = cumSum[k-1];
                
                for(j=jc[i];j<jc[i+1];j++)
                    w[ir[j]] -= alpha*Xt[j]*sig/c;
            }
            else {
                if (k==0)
                    cumSum[0] = alpha/c;
                else
                    cumSum[k] = cumSum[k-1] + alpha/c;
                for(j=jc[i];j<jc[i+1];j++)
                    w[ir[j]] -= alpha*(Xt[j]*(sig-sigOld))/c;
            }
        }
        else {
            for(j=0;j<nVars;j++) {
                w[j] *= 1-alpha*lambda;
            }
            
            if (doSingles && covered[i]==0) {
                for(j=0;j<nVars;j++)
                    w[j] -= alpha*Xt[j + nVars*i]*sig;
            }
            else {
                for(j=0;j<nVars;j++)
                    w[j] -= alpha*(Xt[j + nVars*i]*(sig-sigOld) + d[j]);
            }
        }
        
       if (trackSum && (!doSingles || covered[i]==1)) {
            if (sparse) {
                for(j=jc[i];j<jc[i+1];j++)
                    gSum[ir[j]] += Xt[j]*sigOld;
            }   
            else {
                for(j=0;j<nVars;j++)
                    gSum[j] += Xt[j + nVars*i]*sigOld;
            }
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
