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
fix_window      = 3;
fix_wait        = 5000;  % ms to choose
reward          = 100;   % ms per water pulse
iti             = 50;
max_trials_edit = 500;

BUTTON = 10;
REWARD = 90;
PUFF   = 91;
bhv_code(BUTTON,'Button',REWARD,'Reward',PUFF,'Puff');

% ----------------- Cue (TaskObject #1) -----------------
fix_start = SingleTarget(tracker);
fix_start.Target    = 1;
fix_start.Threshold = fix_window;

fst_start = WaitThenHold(fix_start);
fst_start.WaitTime = fix_wait;
fst_start.HoldTime = 300;

scene_start = create_scene(fst_start, 1);

% ----------------- Choice: water (#2) vs puff (#4) -----------------
choice = MultiTarget(tracker);
choice.Target    = [2 4];    % 2 = water, 4 = puff
choice.Threshold = fix_window;
choice.WaitTime  = fix_wait;
choice.HoldTime  = 0;

scene_choice = create_scene(choice, [2 4]);

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
    % Choice
    run_scene(scene_choice, BUTTON);
    rt_touch = choice.RT;

    % Show debug info (you can remove later)
    dashboard(1, sprintf('Targets: %s', mat2str(choice.Target)), [1 1 0]);
    dashboard(2, sprintf('ChosenTarget: %d', choice.ChosenTarget), [1 1 0]);

    if isempty(choice.ChosenTarget) || choice.ChosenTarget == 0
        error_type = 1;
    else
        % IMPORTANT: ChosenTarget is TO index (2 or 4), not 1 or 2
        if choice.ChosenTarget == 2
            chose_water = true;
        elseif choice.ChosenTarget == 4
            chose_puff = true;
        end
    end
end

% ----------------- Outcome -----------------
if error_type == 0
    if chose_water
        dashboard(1,'WATER CHOSEN',[0 1 0]);
        run_scene(sndscene_cor1);

        % water1 = 1 pulse, water2 = 2, water3 = 3
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
        dashboard(1,'PUFF CHOSEN',[1 0 0]);

        % puff1 = 100 ms, puff2 = 250 ms, puff3 = 400 ms
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
