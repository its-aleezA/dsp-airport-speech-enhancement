function results = compute_all_metrics(clean_signals, noisy_signals, ...
                                        enhanced_signals, file_labels, Fs)
% COMPUTE_ALL_METRICS  Compute and display all required objective metrics.
%
% Called TWICE in the project pipeline:
%   1. By ibrahim_analysis.m with enhanced_signals = noisy_signals  →  baseline
%   2. By Shaheer's filter script with enhanced_signals = filtered output  →  results
%
% Syntax:
%   results = compute_all_metrics(clean_signals, noisy_signals, ...
%                                  enhanced_signals, file_labels, Fs)
%
% Inputs:
%   clean_signals    - Cell array of clean reference vectors
%   noisy_signals    - Cell array of noisy input vectors (for baseline SNR)
%   enhanced_signals - Cell array of enhanced (or noisy, for baseline) vectors
%   file_labels      - Cell array of sentence ID strings
%   Fs               - Sampling frequency (Hz)
%
% Output:
%   results - Struct with fields:
%       .segsnr      - Per-sentence SegSNR (dB)
%       .pesq        - Per-sentence PESQ score
%       .mse         - Per-sentence MSE
%       .proc_time   - Per-sentence processing time (s) [set externally if needed]
%       .mean_*      - Mean values across sentences
%
% Authors: Ibrahim — EC-313 CEP Group

    N = numel(clean_signals);
    if nargin < 5, Fs = 8000; end

    results.segsnr    = zeros(N, 1);
    results.pesq      = zeros(N, 1);
    results.mse       = zeros(N, 1);
    results.proc_time = zeros(N, 1);  % to be filled by Shaheer's timer

    fprintf('\n%s\n', repmat('=', 1, 58));
    fprintf('  OBJECTIVE METRICS SUMMARY\n');
    fprintf('%s\n', repmat('=', 1, 58));
    fprintf('%-8s  %+10s  %8s  %14s\n', 'Sentence', 'SegSNR(dB)', 'PESQ', 'MSE');
    fprintf('%s\n', repmat('-', 1, 58));

    for k = 1:N
        xc  = clean_signals{k}(:);
        xn  = noisy_signals{k}(:);
        xe  = enhanced_signals{k}(:);

        % Equalise lengths
        L = min([length(xc), length(xn), length(xe)]);
        xc = xc(1:L); xn = xn(1:L); xe = xe(1:L);  %#ok<NASGU>

        % ── SegSNR ────────────────────────────────────────────────────────
        results.segsnr(k) = compute_segsnr(xc, xe, Fs);

        % ── MSE ───────────────────────────────────────────────────────────
        results.mse(k) = mean((xc - xe).^2);

        % ── PESQ ──────────────────────────────────────────────────────────
        % Requires MATLAB Audio Toolbox (R2020b+).
        % If unavailable, NaN is stored and a warning is shown once.
        try
            results.pesq(k) = pesq(xc, xe, Fs);
        catch ME
            if k == 1
                warning(['pesq() not available: ' ME.message ...
                    '\nInstall Audio Toolbox or use the ITU P.862 binary.']);
            end
            results.pesq(k) = NaN;
        end

        fprintf('%-8s  %+10.3f  %8.3f  %14.6e\n', ...
            file_labels{k}, results.segsnr(k), results.pesq(k), results.mse(k));
    end

    fprintf('%s\n', repmat('-', 1, 58));

    results.mean_segsnr = mean(results.segsnr);
    results.mean_pesq   = nanmean(results.pesq);
    results.mean_mse    = mean(results.mse);

    fprintf('%-8s  %+10.3f  %8.3f  %14.6e\n', 'MEAN', ...
        results.mean_segsnr, results.mean_pesq, results.mean_mse);
    fprintf('%s\n\n', repmat('=', 1, 58));
end
