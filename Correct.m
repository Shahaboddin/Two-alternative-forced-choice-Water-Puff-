%% -------- SETTINGS --------
bhvfile = '260327_Rosa_ChoiceWW_userloop.bhv2';   % <- change this

%% -------- LOAD DATA --------
data = mlread(bhvfile);
ntr  = numel(data);

% pre-allocate
hc  = nan(1,ntr);   % higher_chosen
hs  = nan(1,ntr);   % higher_side
cs  = nan(1,ntr);   % chose_side (1/2/0)
tRT = nan(1,ntr);   % touch_rt
it1 = nan(1,ntr);   % img1_type (1=water,0=other)
it2 = nan(1,ntr);   % img2_type (1=water,0=other)

for i = 1:ntr
    if isfield(data(i).UserVars,'higher_chosen'), hc(i) = data(i).UserVars.higher_chosen; end
    if isfield(data(i).UserVars,'higher_side'),  hs(i) = data(i).UserVars.higher_side;   end
    if isfield(data(i).UserVars,'chose_side'),   cs(i) = data(i).UserVars.chose_side;    end
    if isfield(data(i).UserVars,'touch_rt'),     tRT(i) = data(i).UserVars.touch_rt;     end
    if isfield(data(i).UserVars,'img1_type'),    it1(i) = data(i).UserVars.img1_type;    end
    if isfield(data(i).UserVars,'img2_type'),    it2(i) = data(i).UserVars.img2_type;    end
end

%% -------- CLASSIFY TRIALS: reward vs non-reward choice --------
% chose_side: 1 -> image1, 2 -> image2, 0 -> no valid choice
is_choice   = cs ~= 0 & ~isnan(cs);

% for each trial, what type was actually chosen? (1=water,0=other,NaN=no choice)
chosen_type = nan(1,ntr);
idx1 = cs == 1;
idx2 = cs == 2;
chosen_type(idx1) = it1(idx1);
chosen_type(idx2) = it2(idx2);

is_reward    = is_choice & chosen_type == 1;
is_nonreward = is_choice & chosen_type == 0;

n_trials        = ntr;
n_choice        = sum(is_choice);
n_no_choice     = n_trials - n_choice;
n_reward_choice = sum(is_reward);
n_nonrew_choice = sum(is_nonreward);

pct_reward    = 100 * n_reward_choice / n_choice;
pct_nonreward = 100 * n_nonrew_choice / n_choice;

%% -------- REACTION TIMES --------
rt_reward    = tRT(is_reward & ~isnan(tRT));
rt_nonreward = tRT(is_nonreward & ~isnan(tRT));

mean_rt_reward    = mean(rt_reward);
mean_rt_nonreward = mean(rt_nonreward);

%% -------- PRINT SUMMARY IN ONE BLOCK --------
fprintf('File: %s\n', bhvfile);
fprintf('Total trials           : %d\n', n_trials);
fprintf('Trials with a choice   : %d\n', n_choice);
fprintf('Trials with no choice  : %d\n', n_no_choice);
fprintf('Reward choices         : %d (%.1f %%)\n', n_reward_choice, pct_reward);
fprintf('Non-reward choices     : %d (%.1f %%)\n', n_nonrew_choice, pct_nonreward);

if ~isempty(rt_reward)
    fprintf('Mean RT (reward)       : %.1f ms (n = %d)\n', mean_rt_reward, numel(rt_reward));
else
    fprintf('Mean RT (reward)       : NaN (no reward choices)\n');
end

if ~isempty(rt_nonreward)
    fprintf('Mean RT (non-reward)   : %.1f ms (n = %d)\n', mean_rt_nonreward, numel(rt_nonreward));
else
    fprintf('Mean RT (non-reward)   : NaN (no non-reward choices)\n');
end

%% -------- PLOT 1: number of reward vs non-reward choices --------
figure;
bar(1, n_reward_choice, 'FaceColor',[0 0.6 0]); hold on;
bar(2, n_nonrew_choice, 'FaceColor',[0.7 0 0]);
set(gca,'XTick',[1 2],'XTickLabel',{'Reward','Non-reward'});
ylabel('Number of trials');
title(sprintf('Choices: %s', bhvfile));
grid on;

%% -------- PLOT 2: mean RT reward vs non-reward --------
figure;
means = [mean_rt_reward, mean_rt_nonreward];
bar(1, means(1), 'FaceColor',[0 0.6 0]); hold on;
bar(2, means(2), 'FaceColor',[0.7 0 0]);
set(gca,'XTick',[1 2],'XTickLabel',{'Reward','Non-reward'});
ylabel('Mean RT (ms)');
title(sprintf('Reaction times: %s', bhvfile));
grid on;
