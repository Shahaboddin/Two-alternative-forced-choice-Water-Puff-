function [C,timingfile,userdefined_trialholder] = ChoiceWater_userloop(~, TrialRecord)

% 1) Default outputs
C = [];
timingfile = 'ChoiceWater.m';
userdefined_trialholder = '';

% 2) Max trials (from timing file if available)
max_trials = 800;
if isfield(TrialRecord,'Editable') && isfield(TrialRecord.Editable,'max_trials_edit')
    max_trials = TrialRecord.Editable.max_trials_edit;
end

% 3) Stop after N trials
if TrialRecord.CurrentTrialNumber >= max_trials
    TrialRecord.NextBlock = -1;
    return;
end

% 4) Define positions
cx = 0;   cy = -12;   % center
rx = 7;   ry = -14;   % right
lx = -7;  ly = -14;   % left

all_button_locs = [ ...
    cx  cy; ...
    rx  ry; ...
    lx  ly];

% 5) Choose 2 distinct positions this trial
pos_idx = randperm(3,2);
pos1    = all_button_locs(pos_idx(1),:);
pos2    = all_button_locs(pos_idx(2),:);

% 6) Image pool: Zero + 3 water levels
image_names   = {'Zero.png','water1.png','water2.png','water3.png'};
reward_pulses = [0          1           2           3];

% pick 2 distinct images from the 4
pair_idx    = randperm(4,2);
idx1        = pair_idx(1);
idx2        = pair_idx(2);

img1_name   = image_names{idx1};
img2_name   = image_names{idx2};
img1_pulses = reward_pulses(idx1);    % 0,1,2,3
img2_pulses = reward_pulses(idx2);    % 0,1,2,3

% 7) Save for analysis
TrialRecord.User.all_button_locs = all_button_locs;
TrialRecord.User.pos_idx_pair    = pos_idx;
TrialRecord.User.pos1            = pos1;
TrialRecord.User.pos2            = pos2;

TrialRecord.User.img1_index      = idx1;          % 1..4 (Zero, w1, w2, w3)
TrialRecord.User.img2_index      = idx2;
TrialRecord.User.img1_pulses     = img1_pulses;
TrialRecord.User.img2_pulses     = img2_pulses;

% which image is higher / lower?
if img1_pulses > img2_pulses
    TrialRecord.User.higher_side = 1;   % image1 is higher
    TrialRecord.User.lower_side  = 2;
elseif img2_pulses > img1_pulses
    TrialRecord.User.higher_side = 2;   % image2 is higher
    TrialRecord.User.lower_side  = 1;
else
    TrialRecord.User.higher_side = 0;   % equal (e.g. Zero vs Zero or w1 vs w1)
    TrialRecord.User.lower_side  = 0;
end

% 8) Build TaskObjects
normal_size    = 150;
highlight_size = round(1.4 * normal_size);

% layout:
% #1 cue
% #2 image1 normal
% #3 image1 big
% #4 image2 normal
% #5 image2 big

C = { ...
    'crc(2,[1 1 1],1,0,-17)', ...  % #1 cue
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', img1_name, pos1(1), pos1(2), normal_size,    normal_size), ...    % #2
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', img1_name, pos1(1), pos1(2), highlight_size, highlight_size), ... % #3
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', img2_name, pos2(1), pos2(2), normal_size,    normal_size), ...    % #4
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', img2_name, pos2(1), pos2(2), highlight_size, highlight_size) ...  % #5
    };

end
