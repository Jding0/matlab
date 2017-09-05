StochBFGS: Stochastic Block BFGS
---------------------------------------------------------------------------

1. Introduction
===============

This is an implementation of the stochastic block BFGS method for solving the 
empirical risk minimization problems with a logistic loss and L2 regularizer. 
The details of the method can be found in:

[1]   Robert M. Gower, Donald Goldfarb and Peter Richtarik
      Stochastic Block BFGS: Squeezing More Curvature out of Data, 2016.


For comparisons, this package also includes an implementation of the SVRG 
method and a stochastic L-BFGS method proposed in [2]. 

2. Installation and Setup
=========================

Start Matlab and make sure that the working directory is set to the
main directory of the present package.  At the MATLAB prompt, run

  >> setuppaths

The script adds the appropriate directories in the MATLAB path and runs mex 
on libsvmread.c, used to load the logistic problems. 

To test if the installation and setup for the quNac have been 
completed successfully please run in the MATLAB prompt:

  >> demo

3. Repeat tests in paper [1]
============================

WARNING: The following experiments are CPU and memory intensive!

To run the tests carried out in the paper [1] do the following.
First download seven LIBSVM data files using the following script

  >>  get_LIBSVM_data

NOTE:  the script 'get_LIBSVM_data' will download approx 1 GB to your local hard drive. If this script fails, please manually download all seven LIBSVM files to the folder StochBFGS/tests/logistic/LIBSVM_data.

To repeat all experiments in [1],  run the commands

  >>  problems = {    'covtype.libsvm.binary',   'gisette_scale',  'SUSY', 'url_combined',     'HIGGS' , 'epsilon_normalized', 'rcv1_train.binary' } 
  >>  test_problems_opt_step_size(problems)

4. References
==============

[1]   Robert M. Gower, Donald Goldfarb and Peter Richtarik
      Stochastic Block BFGS: Squeezing More Curvature out of Data

[2]   P. Moritz, R. Nishihara, and M. I. Jordan. 
      “A linearly-convergent stochastic L-BFGS algorithm”.
      arXiv:1508.02087v1 (2015).

5. License
==========

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.

6. Bugs and Comments
==============

If you have any bug reports or comments, please feel free to email 

  Robert Gower <r.m.gower@sms.ed.ac.uk>
  Robert Gower <gowerrobert@gmail.com>


Robert Gower
30 March 2016
