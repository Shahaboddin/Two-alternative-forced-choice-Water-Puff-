%% -------- SETTINGS --------
bhvfile = '260325__ChoiceWW_userloop.bhv2';   % <- change this

%% -------- LOAD DATA --------
data = mlread(bhvfile);
ntr  = numel(data);

% pre-allocate
hc = nan(1,ntr);   % higher_chosen
hs = nan(1,ntr);   % higher_side
cs = nan(1,ntr);   % chose_side

for i = 1:ntr
    if isfield(data(i).UserVars,'higher_chosen')
        hc(i) = data(i).UserVars.higher_chosen;
    end
    if isfield(data(i).UserVars,'higher_side')
        hs(i) = data(i).UserVars.higher_side;
    end
    if isfield(data(i).UserVars,'chose_side')
        cs(i) = data(i).UserVars.chose_side;
    end
end

%% -------- COMPUTE % HIGHER CHOSEN --------
% valid = trials where there was a strictly higher option and a valid choice
valid = hs ~= 0 & cs ~= 0 & ~isnan(hc);

if any(valid)
    percent_higher = 100 * sum(hc(valid) == 1) / sum(valid);
else
    percent_higher = NaN;
end

fprintf('Percent higher chosen = %.1f %% (n = %d valid trials)\n', ...
        percent_higher, sum(valid));

%% -------- OPTIONAL: quick plot over trials --------
figure; 
plot(hc,'ko-','MarkerFaceColor','k');
xlabel('Trial'); ylabel('Higher chosen (1=yes,0=no)');
title(sprintf('Session: %s  |  %% higher = %.1f', bhvfile, percent_higher));
grid on;
