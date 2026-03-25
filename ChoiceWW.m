showcursor('off');
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');

tracker = touch_;

% Sounds
snd_cor1 = AudioSound(null_);
snd_err1 = AudioSound(null_);
snd_cor1.List = 'load_waveform({''sin'', .1, 800})';
snd_err1.List = 'load_waveform({''sin'', .2, 200})';
sndscene_cor1 = create_scene(snd_cor1);
sndscene_err1 = create_scene(snd_err1);

% Editables
editable('fix_window','fix_wait','fix_hold','reward','iti','max_trials_edit');
fix_window      = 3;        % cue radius (circle)
fix_wait        = 5000;
fix_hold        = 200;
reward          = 50;       % ms per pulse (baseline)
iti             = 50;
max_trials_edit = 800;

% rectangular-ish window for the images (x_radius, y_radius)
obj_window      = [6 4];

BUTTON = 10;
REWARD = 90;
bhv_code(BUTTON,'Button',REWARD,'Reward');

% ---------- Scene 0: central white circle (TaskObject #1) ----------
fix_start = SingleTarget(tracker);
fix_start.Target    = 1;
fix_start.Threshold = fix_window;   % circle

fst_start = FreeThenHold(fix_start);
fst_start.WaitTime = fix_wait;
fst_start.HoldTime = 300;

scene_start = create_scene(fst_start, 1);

% ---------- Scene 1: acquire one of the normal images (#2 or #4) ----------
choice_acq = MultiTarget(tracker);
choice_acq.Target    = [2 4];      % 2 = image1, 4 = image2
choice_acq.Threshold = obj_window; % [6 4]
choice_acq.WaitTime  = fix_wait;
choice_acq.HoldTime  = 0;          % quick touch selects which branch

scene_acq = create_scene(choice_acq, [2 4]);

% ---------- Scene 2a: enlarged image1 (TaskObject #3) with FreeThenHold ----------
hold1_st = SingleTarget(tracker);
hold1_st.Target    = 3;
hold1_st.Threshold = obj_window;

hold1 = FreeThenHold(hold1_st);
hold1.WaitTime = fix_wait;
hold1.HoldTime = fix_hold;

scene_hold1 = create_scene(hold1, 3);

% ---------- Scene 2b: enlarged image2 (TaskObject #5) with FreeThenHold ----------
hold2_st = SingleTarget(tracker);
hold2_st.Target    = 5;
hold2_st.Threshold = obj_window;

hold2 = FreeThenHold(hold2_st);
hold2.WaitTime = fix_wait;
hold2.HoldTime = fix_hold;

scene_hold2 = create_scene(hold2, 5);

% ---------- Run trial ----------
error_type   = 0;
rt_touch     = NaN;
chose_img1   = false;
chose_img2   = false;
num_rew      = NaN;
higher_chosen = 0;  % 1 if higher option chosen, 0 otherwise

idle(500);

% Scene 0: cue
run_scene(scene_start);
if ~fst_start.Success
    error_type = 1;
else
    % Scene 1: acquire one of the two images
    run_scene(scene_acq, BUTTON);
    rt_touch = choice_acq.RT;

    if isempty(choice_acq.ChosenTarget) || choice_acq.ChosenTarget == 0
        error_type = 1;
    else
        if choice_acq.ChosenTarget == 2
            % chose image1 -> enlarged #3, hold 200 ms
            run_scene(scene_hold1);
            if ~hold1.Success
                error_type = 3;
            else
                chose_img1 = true;
                num_rew    = TrialRecord.User.img1_pulses;
            end

        elseif choice_acq.ChosenTarget == 4
            % chose image2 -> enlarged #5, hold 200 ms
            run_scene(scene_hold2);
            if ~hold2.Success
                error_type = 3;
            else
                chose_img2 = true;
                num_rew    = TrialRecord.User.img2_pulses;
            end
        end
    end
end

% Was the higher option chosen on this trial?
% higher_side: 1=image1, 2=image2, 0=equal
if TrialRecord.User.higher_side ~= 0
    if (TrialRecord.User.higher_side == 1 && chose_img1) || ...
       (TrialRecord.User.higher_side == 2 && chose_img2)
        higher_chosen = 1;
    else
        higher_chosen = 0;
    end
else
    % equal amounts: treat as NaN / 0; you can filter later
    higher_chosen = 0;
end

% Reward / error
if error_type == 0
    run_scene(sndscene_cor1);

    % Pulsed reward: pulses depend on chosen object (1,2,3)
    reward        = 50;       % ms per pulse (tune)
    base_pause_ms = 200;      % gap between pulses

    for k = 1:num_rew
        idle(150);  % small delay before each pulse
        goodmonkey(reward,'numreward',1,'eventmarker',REWARD);
        if k < num_rew
            idle(base_pause_ms);
        end
    end
else
    run_scene(sndscene_err1);
end

idle(iti);

trialerror(error_type);

% ---------- Save variables to bhv ----------
bhv_variable('pos1',         TrialRecord.User.pos1);
bhv_variable('pos2',         TrialRecord.User.pos2);
bhv_variable('img_idx1',     TrialRecord.User.img_idx1);
bhv_variable('img_idx2',     TrialRecord.User.img_idx2);
bhv_variable('img1_pulses',  TrialRecord.User.img1_pulses);
bhv_variable('img2_pulses',  TrialRecord.User.img2_pulses);
bhv_variable('higher_side',  TrialRecord.User.higher_side);      % 1=image1, 2=image2, 0=equal
bhv_variable('chose_side',   double(chose_img1)*1 + double(chose_img2)*2); % 1 or 2
bhv_variable('higher_chosen', higher_chosen);                    % 1 if chose higher
bhv_variable('touch_rt',     rt_touch);
bhv_variable('num_pulses',   num_rew);
