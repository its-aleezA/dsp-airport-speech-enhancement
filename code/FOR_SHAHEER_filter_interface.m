% =========================================================================
% shaheer_filter.m
% Purpose : Design and apply a bandpass filter to suppress airport noise.
%           Saves filtered signals to enhanced_signals.mat for evaluation.
% Author  : Shaheer
% =========================================================================
clc; clear; close all;

%% 1. Load Ibrahim's Baseline Workspace
fprintf('Loading baseline_metrics.mat...\n');
if ~isfile('baseline_metrics.mat')
    error('baseline_metrics.mat not found! Ask Ibrahim to run his analysis script first.');
end
load('baseline_metrics.mat'); % Loads: clean_signals, noisy_signals, Fs, file_labels

%% 2. Filter Design
% Rationale: Airport noise has a strong low-frequency rumble (< 300 Hz).
% Speech formants primarily exist between 300 Hz and 3400 Hz.
% A bandpass filter preserves the speech band while heavily attenuating
% out-of-band noise (both low-end rumble and high-end hiss).
%
% NOTE: butter() is called in zero-pole-gain form [z,p,k] instead of
% transfer-function form [b,a]. For a 6th-order bandpass the internal
% order doubles to 12, making direct-form [b,a] coefficients numerically
% unstable. Converting to second-order sections (SOS) via zp2sos() and
% filtering with sosfilt() avoids this entirely.
F_low   = 300;   % Lower cutoff frequency (Hz)
F_high  = 3400;  % Upper cutoff frequency (Hz)
N_order = 2;     % Filter order

Wn  = [F_low F_high] / (Fs/2);           % Normalise to Nyquist
[z, p, k] = butter(N_order, Wn, 'bandpass');
sos = zp2sos(z, p, k);                   % Convert to second-order sections

fprintf('Filter Designed: %d-order Butterworth Bandpass (%d-%d Hz)\n', ...
        N_order, F_low, F_high);

%% 3. Plot and Save Filter Responses for A.'s Report
fig_dir = 'figures';
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end

% Frequency Response
fig_freq = figure('Name', 'Filter Frequency Response', 'Visible', 'off');
freqz(sos, 1024, Fs);
title(sprintf('%d-order Butterworth Bandpass Filter Frequency Response', N_order));
savefig(fig_freq, fullfile(fig_dir, 'shaheer_freq_response.fig'));
exportgraphics(fig_freq, fullfile(fig_dir, 'shaheer_freq_response.png'), 'Resolution', 150);

% Group Delay
fig_gd = figure('Name', 'Filter Group Delay', 'Visible', 'off');
grpdelay(sos, 1024, Fs);
title(sprintf('%d-order Butterworth Bandpass Filter Group Delay', N_order));
savefig(fig_gd, fullfile(fig_dir, 'shaheer_group_delay.fig'));
exportgraphics(fig_gd, fullfile(fig_dir, 'shaheer_group_delay.png'), 'Resolution', 150);

fprintf('Saved frequency response and group delay figures to %s/\n', fig_dir);

%% 4. Filtering Loop & Processing Time
N = numel(noisy_signals);
enhanced_signals = cell(N, 1);
proc_times       = zeros(N, 1);

fprintf('\nApplying filter to %d noisy signals...\n', N);
for k = 1:N
    x_in = noisy_signals{k};

    t_start = tic;
    x_out   = sosfilt(sos, x_in);   % Numerically stable SOS filtering
    proc_times(k)       = toc(t_start);
    enhanced_signals{k} = x_out;
end

%% 5. Save Output
save('enhanced_signals.mat', 'enhanced_signals', 'proc_times');
fprintf('\nenhanced_signals.mat saved — hand back to Ibrahim.\n');

%% 6. Quick Sanity Check (Audio Playback)
fprintf('\nPlaying original noisy signal (sp01) ...\n');
sound(noisy_signals{1}, Fs);
pause(length(noisy_signals{1})/Fs + 0.5);
fprintf('Playing filtered signal (sp01) ...\n');
sound(enhanced_signals{1}, Fs);
