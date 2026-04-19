% =========================================================================
% FOR_SHAHEER_filter_interface.m
% Purpose : Shows exactly how Shaheer must save his filtered outputs so
%            ibrahim_postfilter_eval.m can load and evaluate them.
%
% Shaheer — copy the pattern below into the END of your filter script.
% =========================================================================

% ── TIMING: wrap your filtering loop like this ───────────────────────────

% Load Ibrahim's baseline workspace first
load('baseline_metrics.mat');   % gives you: clean_signals, noisy_signals, Fs, file_labels

N = numel(noisy_signals);
enhanced_signals = cell(N, 1);
proc_times       = zeros(N, 1);

for k = 1:N
    x_in = noisy_signals{k};    % input to your filter

    t_start = tic;

    %  ▼▼▼  YOUR FILTER CODE GOES HERE  ▼▼▼
    %  Example:
    %    x_out = filter(b, a, x_in);
    %  Replace with your actual filter call(s).
    x_out = x_in;               % <-- REPLACE THIS LINE

    proc_times(k)       = toc(t_start);
    enhanced_signals{k} = x_out;
end

% Save for Ibrahim's evaluator
save('enhanced_signals.mat', 'enhanced_signals', 'proc_times');
fprintf('enhanced_signals.mat saved — hand back to Ibrahim.\n');

% ── QUICK SANITY CHECK ───────────────────────────────────────────────────
% Play the first sentence to confirm the filter is doing something useful
fprintf('\nPlaying original noisy signal (sp01) ...\n');
sound(noisy_signals{1}, Fs); pause(length(noisy_signals{1})/Fs + 0.5);
fprintf('Playing filtered signal ...\n');
sound(enhanced_signals{1}, Fs);
