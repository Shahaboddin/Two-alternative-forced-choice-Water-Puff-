showcursor('off');
hotkey('x','escape_screen(); assignin(''caller'',''continue_'',false);');

tracker = touch_;

% ----------------- Sounds -----------------
snd_cor1 = AudioSound(null_);
snd_err1 = AudioSound(null_);
snd_cor1.List = 'load_waveform({''sin'', .1, 800})';
snd_err1.List = 'load_waveform({''sin'', .2, 200})';
sndscene_cor1 = create_scene(snd_cor1);
sndscene_err1 = create_scene(snd_err1);

% ----------------- Editables -----------------
editable('fix_window','fix_wait','reward','iti','max_trials_edit');

fix_window      = 3;       % scalar -> circular cue window
fix_wait        = 5000;    % ms to choose
reward          = 100;     % ms per water pulse
iti             = 50;
max_trials_edit = 500;

% rectangular-ish window for objects (x_radius, y_radius)
obj_window      = [6 4];

BUTTON = 10;
REWARD = 90;
PUFF   = 91;
bhv_code(BUTTON,'Button',REWARD,'Reward',PUFF,'Puff');

% ----------------- Cue (TaskObject #1) -----------------
fix_start = SingleTarget(tracker);
fix_start.Target    = 1;
fix_start.Threshold = fix_window;   % circle

fst_start = FreeThenHold(fix_start);
fst_start.WaitTime = fix_wait;
fst_start.HoldTime = 300;

scene_start = create_scene(fst_start, 1);

% ----------------- Choice Stage 1: first touch (MultiTarget) -----------------
choice = MultiTarget(tracker);
choice.Target    = [2 4];        % 2 = water, 4 = puff
choice.Threshold = obj_window;   % [x y] -> rectangle-like
choice.WaitTime  = fix_wait;
choice.HoldTime  = 0;            % just detect first touch

scene_choice = create_scene(choice, [2 4]);

% ----------------- Choice Stage 2: require 200 ms hold on chosen object -----------------
hold_required = 200;   % ms continuous hold (change to 250 if you want)

% Water hold scene (#2)
water_hold_st = SingleTarget(tracker);
water_hold_st.Target    = 2;
water_hold_st.Threshold = obj_window;   % same rectangle-like window

water_hold = FreeThenHold(water_hold_st);
water_hold.WaitTime = 1000;             % 1 s to re-acquire after first touch
water_hold.HoldTime = hold_required;

scene_water_hold = create_scene(water_hold, 2);

% Puff hold scene (#4)
puff_hold_st = SingleTarget(tracker);
puff_hold_st.Target    = 4;
puff_hold_st.Threshold = obj_window;

puff_hold = FreeThenHold(puff_hold_st);
puff_hold.WaitTime = 1000;
puff_hold.HoldTime = hold_required;

scene_puff_hold = create_scene(puff_hold, 4);

% ----------------- TTL for puff (TTL1) -----------------
ttl_puff = TTLOutput(null_);
ttl_puff.Trigger = true;
ttl_puff.Port    = 1;      % TTL1

tc_puff = TimeCounter(ttl_puff);
tc_puff.Duration = 50;     % default, overridden per trial

% ----------------- Run trial -----------------
error_type  = 0;
rt_touch    = NaN;
chose_water = false;
chose_puff  = false;

idle(500);

% Cue
run_scene(scene_start);
if ~fst_start.Success
    error_type = 1;
else
    % Stage 1: which object was touched first (quick touch can decide)
    run_scene(scene_choice, BUTTON);
    rt_touch = choice.RT;

    % (Old debug lines removed)

    if isempty(choice.ChosenTarget) || choice.ChosenTarget == 0
        error_type = 1;
    else
        % Stage 2: enforce ~200 ms hold on that chosen object
        if choice.ChosenTarget == 2       % water object selected
            run_scene(scene_water_hold);
            if ~water_hold.Success
                error_type = 3;           % failed to hold long enough
            else
                chose_water = true;
                % show water level name
                dashboard(1, sprintf('Water%d', TrialRecord.User.water_index), [0 1 0]);
            end

        elseif choice.ChosenTarget == 4   % puff object selected
            run_scene(scene_puff_hold);
            if ~puff_hold.Success
                error_type = 3;
            else
                chose_puff = true;
                % show puff level name
                dashboard(1, sprintf('Puff%d', TrialRecord.User.puff_index), [1 0 0]);
            end
        end
    end
end

% ----------------- Outcome -----------------
if error_type == 0
    if chose_water
        run_scene(sndscene_cor1);

        reward   = 100;    % ms per pulse
        base_gap = 200;
        num_rew  = TrialRecord.User.water_level;  % 1,2,3

        for k = 1:num_rew
            idle(150);
            goodmonkey(reward,'numreward',1,'eventmarker',REWARD);
            if k < num_rew
                idle(base_gap);
            end
        end

    elseif chose_puff
        level = TrialRecord.User.puff_level;  % 1,2,3
        if     level == 1
            puff_duration = 100;
        elseif level == 2
            puff_duration = 250;
        else
            puff_duration = 400;
        end

        eventmarker(PUFF);
        tc_puff.Duration = puff_duration;
        scene_puff_ttl   = create_scene(tc_puff);
        run_scene(scene_puff_ttl);
    end
else
    run_scene(sndscene_err1);
end

idle(iti);

% ----------------- Log variables -----------------
trialerror(error_type);
bhv_variable('water_pos',   TrialRecord.User.water_pos);
bhv_variable('puff_pos',    TrialRecord.User.puff_pos);
bhv_variable('water_level', TrialRecord.User.water_level);
bhv_variable('puff_level',  TrialRecord.User.puff_level);
bhv_variable('touch_rt',    rt_touch);
