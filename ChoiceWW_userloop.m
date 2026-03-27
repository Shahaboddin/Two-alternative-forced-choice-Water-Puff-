function [C,timingfile,userdefined_trialholder] = ChoiceWW_userloop(~, TrialRecord)

% 1) Default outputs
C = [];
timingfile = 'ChoiceWW.m';
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

% 6) Define stimuli
% Water: fixed to water3 (3 pulses)
water_name   = 'water3.png';
water_pulses = 3;

% "Other" objects: Zero / puff2 / puff3
other_names  = {'Zero.png','puff2.png','puff3.png'};
other_codes  = [0 2 3];   % 0=Zero, 2=puff2, 3=puff3 (for timing file)
other_pulses = [0 0 0];   % all non-water (0 pulses)

% Randomly pick which "other" object this trial
o_idx        = randi(3);
this_other   = other_names{o_idx};
this_o_code  = other_codes(o_idx);
this_o_puls  = other_pulses(o_idx);  % always 0

% Now decide which logical image is #1 and #2 (as before),
% but ensure one is water, one is "other".
if rand < 0.5
    % img1 = water, img2 = other
    img1_name   = water_name;
    img2_name   = this_other;
    img1_pulses = water_pulses;
    img2_pulses = this_o_puls;
    img1_type   = 1;   % 1 = water
    img2_type   = 0;   % 0 = other (Zero/puff)
else
    % img1 = other, img2 = water
    img1_name   = this_other;
    img2_name   = water_name;
    img1_pulses = this_o_puls;
    img2_pulses = water_pulses;
    img1_type   = 0;
    img2_type   = 1;
end

% 7) Save for analysis
TrialRecord.User.all_button_locs = all_button_locs;
TrialRecord.User.pos_idx_pair    = pos_idx;
TrialRecord.User.pos1            = pos1;
TrialRecord.User.pos2            = pos2;

TrialRecord.User.img1_name       = img1_name;
TrialRecord.User.img2_name       = img2_name;
TrialRecord.User.img1_pulses     = img1_pulses;
TrialRecord.User.img2_pulses     = img2_pulses;

TrialRecord.User.img1_type       = img1_type;      % 1=water,0=other
TrialRecord.User.img2_type       = img2_type;      % 1=water,0=other
TrialRecord.User.other_code      = this_o_code;    % 0,2,3 for Zero/puff2/puff3

% which image is higher / lower?
if img1_pulses > img2_pulses
    TrialRecord.User.higher_side = 1;   % image1 is higher
    TrialRecord.User.lower_side  = 2;
elseif img2_pulses > img1_pulses
    TrialRecord.User.higher_side = 2;   % image2 is higher
    TrialRecord.User.lower_side  = 1;
else
    TrialRecord.User.higher_side = 0;   % equal amounts
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
