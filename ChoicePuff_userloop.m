function [C,timingfile,userdefined_trialholder] = ChoicePuff_userloop(~, TrialRecord)

% 1) Default outputs
C = [];
timingfile = 'ChoicePuff.m';
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
cx = 0;   cy = -11;   % center
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

% 6) Image pool: Zero + 2 puff levels
% index: 1=Zero, 2=puff2, 3=puff3
image_names = {'Zero.png','puff2.png','puff3.png'};
puff_values = [0          1          2];   % 0 = none, 1 = small, 2 = big (for value)

% pick 2 distinct images from the 3
pair_idx   = randperm(3,2);
idx1       = pair_idx(1);
idx2       = pair_idx(2);

img1_name  = image_names{idx1};
img2_name  = image_names{idx2};
img1_value = puff_values(idx1);    % 0,1,2
img2_value = puff_values(idx2);    % 0,1,2

% 7) Save for analysis
TrialRecord.User.all_button_locs = all_button_locs;
TrialRecord.User.pos_idx_pair    = pos_idx;
TrialRecord.User.pos1            = pos1;
TrialRecord.User.pos2            = pos2;

TrialRecord.User.img1_index      = idx1;        % 1=Zero,2=puff2,3=puff3
TrialRecord.User.img2_index      = idx2;
TrialRecord.User.img1_value      = img1_value;  % 0,1,2
TrialRecord.User.img2_value      = img2_value;

% which image has higher puff "value"?
if img1_value > img2_value
    TrialRecord.User.higher_side = 1;   % image1 higher puff
    TrialRecord.User.lower_side  = 2;
elseif img2_value > img1_value
    TrialRecord.User.higher_side = 2;   % image2 higher puff
    TrialRecord.User.lower_side  = 1;
else
    TrialRecord.User.higher_side = 0;   % equal
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
    'crc(2,[1 1 1],1,0,-19)', ...  % #1 cue
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', img1_name, pos1(1), pos1(2), normal_size,    normal_size), ...    % #2
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', img1_name, pos1(1), pos1(2), highlight_size, highlight_size), ... % #3
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', img2_name, pos2(1), pos2(2), normal_size,    normal_size), ...    % #4
    sprintf('pic(%s,%.1f,%.1f,%d,%d)', img2_name, pos2(1), pos2(2), highlight_size, highlight_size) ...  % #5
    };

end