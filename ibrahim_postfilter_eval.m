% =========================================================================
% ibrahim_postfilter_eval.m
% Purpose : Load Shaheer's enhanced signals, compute final metrics, and
%            generate the annotated comparison spectrograms for the report.
% Inputs  : baseline_metrics.mat  (saved by ibrahim_analysis.m)
%           enhanced_signals.mat  (saved by Shaheer's filter script)
%            └─ must contain: enhanced_signals (cell array, same order
%                             as clean_signals in baseline file),
%                             proc_times (vector, seconds per sentence)
% Outputs : Console metrics table (baseline vs enhanced)
%           Annotated spectrogram .fig + .png for each sentence
%           results_table.mat — all numbers ready for A.'s report table
% Authors : Ibrahim (analysis & metrics) — EC-313 CEP Group
% =========================================================================

clc; clear; close all;

%% ── 0. CONFIGURATION ────────────────────────────────────────────────────
FIG_DIR = '../figures';
if ~exist(FIG_DIR, 'dir'), mkdir(FIG_DIR); end

%% ── 1. LOAD WORKSPACE DATA ──────────────────────────────────────────────
fprintf('Loading baseline metrics workspace ...\n');
load('baseline_metrics.mat');   % → file_labels, all_segsnr, all_pesq, all_mse,
                                %   clean_signals, noisy_signals, Fs

fprintf('Loading Shaheer''s enhanced signals ...\n');
if ~isfile('enhanced_signals.mat')
    error(['enhanced_signals.mat not found.\n' ...
           'Shaheer: save your filtered outputs with:\n' ...
           '  save(''enhanced_signals.mat'', ''enhanced_signals'', ''proc_times'')']);
end
load('enhanced_signals.mat');   % → enhanced_signals (cell), proc_times (vector)

N = numel(clean_signals);

%% ── 2. COMPUTE ENHANCED METRICS ─────────────────────────────────────────
fprintf('\nComputing post-filter metrics ...\n');
enh_results = compute_all_metrics( ...
    clean_signals, noisy_signals, enhanced_signals, file_labels, Fs);

% Attach processing times from Shaheer's timing
enh_results.proc_time = proc_times(:);

%% ── 3. PRINT COMPARISON TABLE ───────────────────────────────────────────
fprintf('%s\n', repmat('=', 1, 72));
fprintf('  RESULTS TABLE  (Baseline → Enhanced)\n');
fprintf('%s\n', repmat('=', 1, 72));
fprintf('%-8s  %12s  %12s  %8s  %8s  %12s\n', ...
    'Sentence', 'SegSNR_base', 'SegSNR_enh', 'PESQ_b', 'PESQ_e', 'ProcTime(s)');
fprintf('%s\n', repmat('-', 1, 72));

for k = 1:N
    fprintf('%-8s  %+12.3f  %+12.3f  %8.3f  %8.3f  %12.4f\n', ...
        file_labels{k}, all_segsnr(k), enh_results.segsnr(k), ...
        all_pesq(k),    enh_results.pesq(k), enh_results.proc_time(k));
end

fprintf('%s\n', repmat('-', 1, 72));
fprintf('%-8s  %+12.3f  %+12.3f  %8.3f  %8.3f  %12.4f\n', 'MEAN', ...
    mean(all_segsnr), enh_results.mean_segsnr, ...
    nanmean(all_pesq), enh_results.mean_pesq, mean(enh_results.proc_time));
fprintf('%s\n\n', repmat('=', 1, 72));

fprintf('SegSNR improvement : %+.3f dB\n', ...
    enh_results.mean_segsnr - mean(all_segsnr));
fprintf('PESQ improvement   : %+.3f\n', ...
    enh_results.mean_pesq - nanmean(all_pesq));
fprintf('MSE improvement    : %.6e → %.6e\n\n', ...
    mean(all_mse), enh_results.mean_mse);

%% ── 4. ANNOTATED COMPARISON SPECTROGRAMS ────────────────────────────────
% Generate clean / noisy / enhanced spectrogram triptych for EACH sentence.
% These are the figures A. will annotate in the report.

for k = 1:N
    xc = clean_signals{k};
    xn = noisy_signals{k};
    xe = enhanced_signals{k};
    L  = min([length(xc) length(xn) length(xe)]);
    xc = xc(1:L); xn = xn(1:L); xe = xe(1:L);

    lbl = file_labels{k};

    fig = figure('Name', ['Spectrogram Triptych — ' lbl], ...
                 'Position', [50 50 1200 700], 'Visible', 'off');

    titles   = {'Clean (Reference)', ...
                'Noisy Input (Airport 5 dB SNR)', ...
                'Enhanced Output (Post-Filter)'};
    signals  = {xc, xn, xe};
    clim_val = [-80 20];

    for p = 1:3
        subplot(3, 1, p)
        spectrogram(signals{p}, hamming(256), 192, 512, Fs, 'yaxis');
        title([titles{p} ' — ' lbl], 'FontSize', 10, 'FontWeight', 'bold');
        ylabel('Freq (kHz)'); xlabel('Time (s)');
        colorbar; clim(clim_val);
        ylim([0 4]);

        % Draw dashed lines marking the telephone speech band
        hold on;
        yline(0.3,  'w--', '300 Hz',  'LabelHorizontalAlignment', 'left', ...
              'FontSize', 8, 'LineWidth', 1.2);
        yline(3.4,  'w--', '3.4 kHz', 'LabelHorizontalAlignment', 'left', ...
              'FontSize', 8, 'LineWidth', 1.2);
    end

    sgtitle(['Spectrogram Comparison — ' lbl], ...
            'FontSize', 13, 'FontWeight', 'bold');

    savefig(fig, fullfile(FIG_DIR, [lbl '_spectrogram_comparison.fig']));
    exportgraphics(fig, fullfile(FIG_DIR, [lbl '_spectrogram_comparison.png']), ...
                   'Resolution', 150);
    close(fig);
    fprintf('  Saved spectrogram triptych: %s\n', lbl);
end

%% ── 5. SAVE FINAL RESULTS FOR REPORT ────────────────────────────────────
results_table.labels          = file_labels;
results_table.baseline_segsnr = all_segsnr;
results_table.enhanced_segsnr = enh_results.segsnr;
results_table.baseline_pesq   = all_pesq;
results_table.enhanced_pesq   = enh_results.pesq;
results_table.baseline_mse    = all_mse;
results_table.enhanced_mse    = enh_results.mse;
results_table.proc_time       = enh_results.proc_time;

save('results_table.mat', 'results_table');
fprintf('\nAll results saved to results_table.mat  →  hand off to A. for the report.\n');
