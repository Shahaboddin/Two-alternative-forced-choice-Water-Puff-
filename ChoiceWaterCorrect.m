%% SETTINGS
bhvfile = '260401__ChoiceWater_userloop.bhv2';

%% LOAD
data = mlread(bhvfile);
ntr  = numel(data);

hc = nan(1,ntr);   % higher_chosen (1/0)
hs = nan(1,ntr);   % higher_side
cs = nan(1,ntr);   % chose_side
rt = nan(1,ntr);   % touch_rt

for i = 1:ntr
    if isfield(data(i).UserVars,'higher_chosen'), hc(i) = data(i).UserVars.higher_chosen; end
    if isfield(data(i).UserVars,'higher_side'),  hs(i) = data(i).UserVars.higher_side;   end
    if isfield(data(i).UserVars,'chose_side'),   cs(i) = data(i).UserVars.chose_side;    end
    if isfield(data(i).UserVars,'touch_rt'),     rt(i) = data(i).UserVars.touch_rt;      end
end

%% VALID TRIALS (unequal options + a choice + RT)
valid = hs ~= 0 & cs ~= 0 & ~isnan(hc) & ~isnan(rt);

% correct = chose higher; incorrect = chose lower
is_correct   = valid & (hc == 1);
is_incorrect = valid & (hc == 0);

percent_higher = 100 * sum(is_correct) / sum(valid);

rt_correct   = rt(is_correct);
rt_incorrect = rt(is_incorrect);

mean_rt_correct   = mean(rt_correct);
mean_rt_incorrect = mean(rt_incorrect);

%% PRINT SUMMARY
fprintf('File: %s\n', bhvfile);
fprintf('Valid unequal-choice trials : %d\n', sum(valid));
fprintf('%% higher chosen            : %.1f %%\n', percent_higher);
fprintf('Correct trials (higher)     : %d\n', sum(is_correct));
fprintf('Incorrect trials (lower)    : %d\n', sum(is_incorrect));

if ~isempty(rt_correct)
    fprintf('Mean RT correct   : %.1f ms (n = %d)\n', mean_rt_correct, numel(rt_correct));
else
    fprintf('Mean RT correct   : NaN (no correct trials)\n');
end

if ~isempty(rt_incorrect)
    fprintf('Mean RT incorrect : %.1f ms (n = %d)\n', mean_rt_incorrect, numel(rt_incorrect));
else
    fprintf('Mean RT incorrect : NaN (no incorrect trials)\n');
end

%% RT PLOT (boxplot with sensible Y axis)
figure;
boxplot([rt_correct(:); rt_incorrect(:)], ...
        [ones(numel(rt_correct),1); 2*ones(numel(rt_incorrect),1)], ...
        'Labels',{'Correct (higher)','Incorrect (lower)'});
ylabel('RT (ms)');
title(sprintf('RT by correctness: %s', bhvfile), 'Interpreter','none');
grid on;

% tighten Y limits around data (+/- 100 ms margin)
allrt = [rt_correct(:); rt_incorrect(:)];
if ~isempty(allrt)
    ymin = min(allrt) - 100;
    ymax = max(allrt) + 100;
    ylim([ymin ymax]);
end
