function dispres_old(type, groupsize, top, nct, Jmax, B )
% DISPRES(type, groupsize, B) displays a summary of the results obtained 
% for a set of different possible options.
%--------------------------------------------------------------------------
% ARGUMENTS
% type      Specifies whether we're looking at a t or a mean stat. Options
%           are 't','smootht' and 'mean'
% groupsize the size of the groups of subjects to test. The options are:
%           20, 25 and 50.
% nct       0/1 whether or not to correct for the non-central t problem.
%           Default is 1.
% top       the number of peaks to average over
% B         the number of bootstrap iterations.
%--------------------------------------------------------------------------
% OUTPUT
% A summary of the data.
%--------------------------------------------------------------------------
% EXAMPLES
% dispres('smootht',20,50)
%[top_bias_boot, top_bias_is, top_bias_naive, top_MSE_boot, top_MSE_is, top_MSE_naive] = 
%--------------------------------------------------------------------------
if nargin < 1
    type = 'smootht';
end
if nargin < 2
   	groupsize = 20;
end
if nargin < 4
    top = 10;
end
if nargin < 7
    B = 50;
end     

if strcmp(type, 't') || strcmp(type, 'smootht') || strcmp(type, 'tstat') || strcmp(type, 'smoothtstat') 
    if nargin < 4
        nct = 1;
    end
elseif strcmp(type, 'SSmean') || strcmp(type, 'SSmeanLM') || strcmp(type, 'sexglm') || strcmp(type,'glmsex') || strcmp(type, 'm') || strcmp(type, 'mean')
    nct = 0;
else
    error('The inputted type is not defined');
end

if strcmp(type, 'm') || strcmp(type,'mean')
    filending = strcat('Results/mean','B',num2str(B),'nsubj',num2str(groupsize),'Data.csv');
elseif strcmp(type, 't') || strcmp(type, 'tstat')
    filending = strcat('Results/tstat','B',num2str(B),'nsubj',num2str(groupsize),'Data.csv');
elseif strcmp(type, 'smootht') || strcmp(type, 'smoothtstat')
    filending = strcat('Results/smoothtstat','B',num2str(B),'nsubj',num2str(groupsize),'Data.csv');
elseif strcmp(type, 'sexglm') || strcmp(type,'glmsex')
    filending = strcat('Results/glmsex','B',num2str(B),'nsubj',num2str(groupsize),'Data.csv');
elseif strcmp(type, 'SSmean')
    filending = '/vols/Scratch/ukbiobank/nichols/SelectiveInf/largefiles/SSmeanB50nsubj20Table.mat';
elseif strcmp(type, 'SSmeanLM')
    filending = strcat('Results/SSmean','B',num2str(B),'nsubj',num2str(groupsize),'LM20Data.csv');
end

try
    if strcmp(type, 'SSmean')
        load(filending);
    else
        M = readtable(jgit(filending));
    end
catch
    error('You don''t have that set of variables stored or there are extra commas!')
end
M = table2array(M);

if nargin < 4
    Jcurrent = M(:,1);
    Jmax = Jcurrent(end);
end


if strcmp(type, 'm') || strcmp(type,'mean')
    fprintf('Results for the mean with nSubj = %d, Jmax = %d and B = %d.\n\n',groupsize,Jmax, B);
elseif strcmp(type, 't')
    fprintf('Results for the t-stat with nSubj = %d, Jmax = %d and B = %d.\n\n',groupsize, Jmax, B);
elseif strcmp(type, 'smootht')
    fprintf('Results for the smooth t-stat with nSubj = %d, Jmax = %d and B = %d.\n\n',groupsize, Jmax, B);
elseif strcmp(type, 'sexglm') || strcmp(type,'glmsex')
    fprintf('Results for the Sex glm with nSubj = %d, Jmax = %d and B = %d.\n\n',groupsize, Jmax, B);
elseif strcmp(type, 'SSmean')
    fprintf('Results for the SSmean with nSubj = %d, Jmax = %d and B = %d.\n\n',groupsize, Jmax, B);
elseif strcmp(type, 'SSmeanLM')
    fprintf('Results for the top SSmean LM with nSubj = %d, Jmax = %d and B = %d.\n\n',groupsize, Jmax, B);
end

boot = M(:,3);

if nct == 1
    naive = M(:,4)/nctcorrection(groupsize); %correcting for non-central t
    is = M(:,7)/nctcorrection(groupsize/2);
else
    naive = M(:,4); %correcting for non-central t
    is = M(:,7);
end


trueatloc = M(:,5);
trueatlocis = M(:,8);

biasboot = boot - trueatloc;
MSEboot = biasboot.^2;

biasnaive = naive - trueatloc;
MSEnaive = biasnaive.^2;

biasis = is - trueatlocis;
MSEis = biasis.^2;

peak_no = M(:,2);
Jiter = max(peak_no);

top_bias_naive = zeros(1,top);
top_bias_boot = zeros(1,top);
top_bias_is = zeros(1,top);
% top_bias_opt = zeros(1,top); Not much point in showing this as we have
% chosen it such that it is zero.

top_MSE_naive = zeros(1,top);
top_MSE_boot = zeros(1,top);
top_MSE_is = zeros(1,top);
top_MSE_opt = zeros(1,top);

optimal_est = zeros(1, length(naive))';

for J = 1:top
    Jthpeak = J:Jiter:(Jiter*Jmax);
    top_bias_naive(J) = mean(biasnaive(Jthpeak));
    top_bias_boot(J) = mean(biasboot(Jthpeak));
    top_bias_is(J) = mean(biasis(Jthpeak));
    
    top_MSE_naive(J) = mean(MSEnaive(Jthpeak));
    top_MSE_boot(J) = mean(MSEboot(Jthpeak));
    top_MSE_is(J) = mean(MSEis(Jthpeak));
    
    optimal_est(Jthpeak) = naive(Jthpeak) - top_bias_naive(J);
end

biasopt = optimal_est - trueatloc;
MSEopt = biasopt.^2;

for J = 1:top
%     top_bias_opt(J) = mean(biasopt(Jthpeak));
	Jthpeak = J:Jiter:(Jiter*Jmax);
    top_MSE_opt(J) = mean(MSEopt(Jthpeak));
end

fprintf('The Bias and MSE averaged over the top %i peaks:\n', top)
fprintf('Average Naive Bias: %0.4f\n',mean(top_bias_naive))
fprintf('Average Boot  Bias: %0.4f\n',mean(top_bias_boot))
fprintf('Average Indep Bias: %0.4f\n\n',mean(top_bias_is))

fprintf('Average Naive MSE: %0.4f\n',mean(top_MSE_naive))
fprintf('Average Boot  MSE: %0.4f\n',mean(top_MSE_boot))
fprintf('Average Indep MSE: %0.4f\n',mean(top_MSE_is))
fprintf('Average Opt   MSE: %0.4f\n\n',mean(top_MSE_opt))
    
top_bias_naive
top_bias_boot
top_bias_is
% top_bias_opt

top_MSE_naive
top_MSE_boot
top_MSE_is
top_MSE_opt

end

