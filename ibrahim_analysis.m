% =========================================================================
% ibrahim_analysis.m
% Purpose : Time-frequency analysis of NOIZEUS airport-noise corpus and
%            computation of baseline (pre-filter) objective metrics.
% Inputs  : Clean speech files  : ../clean/sp<XX>.wav
%           Noisy speech files  : ../noisy/sp<XX>_airport_sn5.wav
%           (adjust DATA_ROOT below to match your folder layout)
% Outputs : Console table of per-sentence and mean metrics
%           Saved .fig + .png figures in ../figures/
% Authors : Ibrahim (analysis & metrics) — EC-313 CEP Group
% Dataset : NOIZEUS corpus (Hu & Loizou, 2007)
% =========================================================================

clc; clear; close all;

%% 0. CONFIGURATION
DATA_ROOT   = '';          % <-- set this to your local NOIZEUS path
CLEAN_DIR   = fullfile(DATA_ROOT, 'clean');
NOISY_DIR   = fullfile(DATA_ROOT, 'noisy');
FIG_DIR     = '../figures';
if ~exist(FIG_DIR, 'dir'), mkdir(FIG_DIR); end

% Sentences to process (sp01 … sp10 as minimum; extend to sp30 for full corpus)
SENTENCE_IDS = 1:10;

Fs = 8000;          % NOIZEUS sampling rate (Hz)

%% 1. BATCH LOAD
fprintf('Loading %d sentence pairs ...\n', numel(SENTENCE_IDS));

clean_signals = cell(numel(SENTENCE_IDS), 1);
noisy_signals = cell(numel(SENTENCE_IDS), 1);
file_labels   = cell(numel(SENTENCE_IDS), 1);

for k = 1:numel(SENTENCE_IDS)
    id = SENTENCE_IDS(k);
    clean_file = fullfile(CLEAN_DIR, sprintf('sp%02d.wav',              id));
    noisy_file = fullfile(NOISY_DIR, sprintf('sp%02d_airport_sn5.wav', id));

    if ~isfile(clean_file) || ~isfile(noisy_file)
        warning('Missing file for sentence %02d — skipping.', id);
        continue
    end

    [x_clean, Fs_c] = audioread(clean_file);
    [x_noisy, Fs_n] = audioread(noisy_file);

    % Enforce mono and matching length
    x_clean = mean(x_clean, 2);
    x_noisy = mean(x_noisy, 2);
    L = min(length(x_clean), length(x_noisy));
    clean_signals{k} = x_clean(1:L);
    noisy_signals{k} = x_noisy(1:L);
    file_labels{k}   = sprintf('sp%02d', id);

    if Fs_c ~= Fs || Fs_n ~= Fs
        warning('Unexpected sample rate for sentence %02d.', id);
    end
end

% Remove any skipped entries
valid = ~cellfun(@isempty, clean_signals);
clean_signals = clean_signals(valid);
noisy_signals = noisy_signals(valid);
file_labels   = file_labels(valid);
N_valid = sum(valid);
fprintf('Loaded %d valid sentence pairs.\n\n', N_valid);

%%   2. DETAILED ANALYSIS ON SENTENCE sp01 
% Full time-domain + PSD + spectrogram analysis shown for the first sentence.
% All figures are saved; summary observations feed the noise characterisation
% section of A.'s report.

idx_demo = 1;   % index into the valid-sentence arrays
x_c = clean_signals{idx_demo};
x_n = noisy_signals{idx_demo};
label = file_labels{idx_demo};

fprintf('=== Detailed analysis: %s ===\n', label);

%   2a. Time-domain waveform comparison
t = (0:length(x_c)-1) / Fs;

fig_td = figure('Name','Time-Domain Comparison','Position',[100 100 900 400]);
subplot(2,1,1)
    plot(t, x_c, 'b', 'LineWidth', 0.8);
    title(['Clean Speech — ' label], 'FontSize', 11);
    xlabel('Time (s)'); ylabel('Amplitude');
    xlim([0 t(end)]); grid on;
subplot(2,1,2)
    plot(t, x_n, 'r', 'LineWidth', 0.8);
    title(['Noisy Speech (Airport, 5 dB SNR) — ' label], 'FontSize', 11);
    xlabel('Time (s)'); ylabel('Amplitude');
    xlim([0 t(end)]); grid on;
sgtitle('Time-Domain Waveform Comparison', 'FontSize', 13, 'FontWeight', 'bold');

savefig(fig_td, fullfile(FIG_DIR, [label '_timedomain.fig']));
exportgraphics(fig_td, fullfile(FIG_DIR, [label '_timedomain.png']), 'Resolution', 150);

%   2b. Power Spectral Density (Welch)   
% Window = 256 samples (32 ms at 8 kHz), 50 % overlap
nfft   = 512;
win    = hamming(256);
novlap = 128;

fig_psd = figure('Name','PSD Comparison','Position',[100 100 800 450]);
[Pxx_c, F_c] = pwelch(x_c, win, novlap, nfft, Fs);
[Pxx_n, F_n] = pwelch(x_n, win, novlap, nfft, Fs);

plot(F_c, 10*log10(Pxx_c), 'b', 'LineWidth', 1.2); hold on;
plot(F_n, 10*log10(Pxx_n), 'r--', 'LineWidth', 1.2);
legend('Clean', 'Noisy (Airport 5 dB)', 'Location', 'NorthEast');
xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)');
title(['Power Spectral Density — ' label], 'FontSize', 12);
xlim([0 Fs/2]); grid on;

% Mark the telephone-band speech region
xline(300,  'k:', 'LineWidth', 1.2);
xline(3400, 'k:', 'LineWidth', 1.2);
text(300,  max(10*log10(Pxx_n))-5, ' 300 Hz', 'FontSize', 9);
text(3400, max(10*log10(Pxx_n))-5, ' 3400 Hz', 'FontSize', 9);

savefig(fig_psd, fullfile(FIG_DIR, [label '_psd.fig']));
exportgraphics(fig_psd, fullfile(FIG_DIR, [label '_psd.png']), 'Resolution', 150);

% Print spectral observations useful for noise characterisation
noise_estimate = Pxx_n - Pxx_c;  % crude noise PSD estimate
[~, peak_bin] = max(noise_estimate(F_n < 1000));  % dominant low-freq noise
fprintf('  Dominant low-freq noise peak ≈ %.0f Hz\n', F_n(peak_bin));
fprintf('  Mean clean PSD in 300–3400 Hz : %.2f dB/Hz\n', ...
    mean(10*log10(Pxx_c(F_c >= 300 & F_c <= 3400))));
fprintf('  Mean noise PSD in 300–3400 Hz : %.2f dB/Hz (delta = %.2f dB)\n', ...
    mean(10*log10(Pxx_n(F_n >= 300 & F_n <= 3400))), ...
    mean(10*log10(Pxx_n(F_n >= 300 & F_n <= 3400))) - ...
    mean(10*log10(Pxx_c(F_c >= 300 & F_c <= 3400))));

%   2c. Spectrograms            
fig_spec = figure('Name','Spectrogram Comparison','Position',[100 100 1000 600]);

subplot(2,1,1)
    spectrogram(x_c, hamming(256), 192, 512, Fs, 'yaxis');
    title(['Clean Speech Spectrogram — ' label], 'FontSize', 11);
    ylim([0 4]);   % 0–4 kHz (full speech band visible)
    colorbar; clim([-80 20]);

subplot(2,1,2)
    spectrogram(x_n, hamming(256), 192, 512, Fs, 'yaxis');
    title(['Noisy Speech Spectrogram (Airport 5 dB SNR) — ' label], 'FontSize', 11);
    ylim([0 4]);
    colorbar; clim([-80 20]);

sgtitle('Spectrogram Comparison (Clean vs Noisy)', 'FontSize', 13, 'FontWeight', 'bold');

savefig(fig_spec, fullfile(FIG_DIR, [label '_spectrogram.fig']));
exportgraphics(fig_spec, fullfile(FIG_DIR, [label '_spectrogram.png']), 'Resolution', 150);

fprintf('  Figures saved to: %s\n\n', FIG_DIR);

%%   3. BATCH BASELINE METRICS
% Compute SegSNR, PESQ, and MSE for ALL loaded sentence pairs.
% These are the pre-filter baselines that will appear in the results table.

fprintf('%-8s  %-10s  %-8s  %-12s\n', 'Sentence', 'SegSNR(dB)', 'PESQ', 'MSE');
fprintf('%s\n', repmat('-', 1, 46));

all_segsnr = zeros(N_valid, 1);
all_pesq   = zeros(N_valid, 1);
all_mse    = zeros(N_valid, 1);

for k = 1:N_valid
    xc = clean_signals{k};
    xn = noisy_signals{k};

    all_segsnr(k) = compute_segsnr(xc, xn, Fs);
    all_mse(k)    = mean((xc - xn).^2);

    % PESQ — requires MATLAB Audio Toolbox or ITU P.862 binary
    try
        all_pesq(k) = pesq(xc, xn, Fs);
    catch
        all_pesq(k) = NaN;   % gracefully degrade if toolbox not available
    end

    fprintf('%-8s  %+10.3f  %8.3f  %12.6e\n', ...
        file_labels{k}, all_segsnr(k), all_pesq(k), all_mse(k));
end

fprintf('%s\n', repmat('-', 1, 46));
fprintf('%-8s  %+10.3f  %8.3f  %12.6e\n', 'MEAN', ...
    mean(all_segsnr), mean(all_pesq,'omitnan'), mean(all_mse));
fprintf('\nNote: PESQ shown as NaN if Audio Toolbox is unavailable.\n');

% Save baseline metrics workspace so Shaheer can load and extend it
save('baseline_metrics.mat', ...
    'file_labels', 'all_segsnr', 'all_pesq', 'all_mse', ...
    'clean_signals', 'noisy_signals', 'Fs');
fprintf('\nBaseline metrics saved to baseline_metrics.mat\n');
