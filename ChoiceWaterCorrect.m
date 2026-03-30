data = mlread('260330__ChoiceWater_userloop.bhv2');
ntr  = numel(data);
hc = nan(1,ntr); hs = nan(1,ntr); cs = nan(1,ntr);

for i = 1:ntr
    if isfield(data(i).UserVars,'higher_chosen'), hc(i) = data(i).UserVars.higher_chosen; end
    if isfield(data(i).UserVars,'higher_side'),  hs(i) = data(i).UserVars.higher_side;   end
    if isfield(data(i).UserVars,'chose_side'),   cs(i) = data(i).UserVars.chose_side;    end
end

valid = hs ~= 0 & cs ~= 0 & ~isnan(hc);      % trials with unequal options and a choice
percent_higher = 100 * sum(hc(valid) == 1) / sum(valid);
fprintf('%% higher chosen = %.1f (n = %d valid trials)\n', percent_higher, sum(valid));
