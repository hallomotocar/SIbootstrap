run = str2num(getenv('SGE_TASK_ID'));
current_run = 0;
number_of_runs = 5;


while current_run < number_of_runs
    current_run = current_run + 1;
    if run == current_run
        niters = 5000;
        full_mean = imgload('fullmean');
        %         for groupsize = (45 + 5*(current_run-1)):(45 + 5*(current_run-1) + 4)
        groupset = (73+current_run):5:100;
        for groupsize = groupset
            if exist(jgit(['AnalyzeData/Thresholds/max_dist_',num2str(groupsize),'.mat']), 'file') == 0
                max_dist = zeros(1, niters);
                groupsize
                for iter = 1:niters
                    iter
                    random_sample = randsample(4945, groupsize);
                    data = getdata( random_sample );
                    subject_mask = loadsubs( random_sample, 'give_mask', 0, '3D');
                    data = data - repmat(full_mean(:)', groupsize, 1);
                    [~,~,~, tstat] = meanmos(data);
                    max_tstat_index = lmindices(tstat, 1, subject_mask);
                    max_dist(iter) = tstat(max_tstat_index);
                end
                save(jgit(['AnalyzeData/Thresholds/max_dist_', num2str(groupsize)]), 'max_dist')
            end
        end
    end
end

%%
% for I = 1:100
%     if exist(jgit(['AnalyzeData/Thresholds/max_dist_',num2str(I),'.mat']), 'file') == 0
%         I
%     end
% end
