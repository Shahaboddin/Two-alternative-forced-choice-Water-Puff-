function [C,timingfile,userdefined_trialholder] = ChoiceWP_userloop(~, TrialRecord)

% 1) Default outputs
C = [];
timingfile = 'ChoiceWP.m';
userdefined_trialholder = '';

% 2) Max trials (from timing file if available)
max_trials = 500;
if isfield(TrialRecord,'Editable') && isfield(TrialRecord.Editable,'max_trials_edit')
    max_trials = TrialRecord.Editable.max_trials_edit;
end

% 3) Stop after N trials
if TrialRecord.CurrentTrialNumber >= max_trials
    TrialRecord.NextBlock = -1;
    return;
end

% 4) Define positions
cx = 0;   cy = -13;   % center
rx = 7;   ry = -14;   % right
lx = -7;  ly = -14;   % left

all_positions = [ ...
    lx ly; ...   % position 1
    cx cy; ...   % position 2
    rx ry];      % position 3
n_pos = size(all_positions,1);

% Choose 2 distinct positions each trial
pos_idx   = randperm(n_pos,2);
water_pos = all_positions(pos_idx(1),:);
puff_pos  = all_positions(pos_idx(2),:);

% 5) Water images and levels (1,2,3 pulses)
water_names  = {'water1.png','water2.png','water3.png'};
water_levels = [1 2 3];

w_idx        = randi(3);
this_water   = water_names{w_idx};
this_w_level = water_levels(w_idx);

% 6) Puff images and levels (1=weak,2=medium,3=strong)
puff_names   = {'puff1.png','puff2.png','puff3.png'};
puff_levels  = [1 2 3];

p_idx        = randi(3);
this_puff    = puff_names{p_idx};
this_p_level = puff_levels(p_idx);

% 7) Save for analysis / timing
TrialRecord.User.water_pos      = water_pos;
TrialRecord.User.puff_pos       = puff_pos;
TrialRecord.User.water_index    = w_idx;
TrialRecord.User.puff_index     = p_idx;
TrialRecord.User.water_level    = this_w_level;   % 1–3 pulses
TrialRecord.User.puff_level     = this_p_level;   % 1–3 (we map to ms below)

% 8) Build TaskObjects:
normal_size    = 150;
highlight_size = round(1.4 * normal_size);

C = { ...
    'crc(2,[1 1 1],1,0,-17)', ...  % #1 cue
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', this_water, water_pos(1), water_pos(2), normal_size,    normal_size), ...    % #2 water normal
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', this_water, water_pos(1), water_pos(2), highlight_size, highlight_size), ... % #3 water big (unused)
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', this_puff,  puff_pos(1),  puff_pos(2),  normal_size,    normal_size), ...    % #4 puff normal
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', this_puff,  puff_pos(1),  puff_pos(2),  highlight_size, highlight_size) ...  % #5 puff big (unused)
    };

end
