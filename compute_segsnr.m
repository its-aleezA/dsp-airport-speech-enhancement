function segsnr_db = compute_segsnr(clean, noisy, Fs)
% COMPUTE_SEGSNR  Compute Segmental SNR between a clean and a noisy/enhanced signal.
%
% Syntax:
%   segsnr_db = compute_segsnr(clean, noisy, Fs)
%
% Inputs:
%   clean     - Clean reference signal (column vector, samples)
%   noisy     - Noisy or enhanced signal (column vector, same length as clean)
%   Fs        - Sampling frequency in Hz (default 8000)
%
% Output:
%   segsnr_db - Mean Segmental SNR in dB
%
% Method:
%   Signal is split into non-overlapping 25 ms frames.
%   Per-frame SNR is computed as 10*log10( energy(clean) / energy(noise) ).
%   Frames with very low clean energy (silence) are excluded to avoid
%   inflating the average, following the convention in Loizou (2007).
%
% Reference:
%   P. Loizou, "Speech Enhancement: Theory and Practice," CRC Press, 2007.
%
% Author: Ibrahim — EC-313 CEP Group

    if nargin < 3, Fs = 8000; end

    % Ensure column vectors of equal length
    clean = clean(:);
    noisy = noisy(:);
    L = min(length(clean), length(noisy));
    clean = clean(1:L);
    noisy = noisy(1:L);

    % Frame parameters
    frame_len = round(0.025 * Fs);   % 25 ms
    hop       = frame_len;            % non-overlapping

    n_frames = floor(L / frame_len);
    snr_vals = zeros(n_frames, 1);
    valid_frames = false(n_frames, 1);

    % Noise signal = difference between noisy/enhanced and clean
    noise = noisy - clean;

    % Silence threshold: frames whose clean energy < 40 dB below peak are skipped
    frame_energies = zeros(n_frames, 1);
    for i = 1:n_frames
        idx = (i-1)*frame_len + 1 : i*frame_len;
        frame_energies(i) = sum(clean(idx).^2);
    end
    energy_thresh = max(frame_energies) * 10^(-40/10);

    for i = 1:n_frames
        idx = (i-1)*frame_len + 1 : i*frame_len;

        e_clean = sum(clean(idx).^2);
        e_noise = sum(noise(idx).^2);

        % Skip silence and zero-noise frames
        if e_clean < energy_thresh || e_noise == 0
            continue
        end

        snr_frame = 10 * log10(e_clean / e_noise);

        % Clip per-frame SNR to [-10, 35] dB as per Loizou convention
        snr_frame = max(-10, min(35, snr_frame));

        snr_vals(i)    = snr_frame;
        valid_frames(i) = true;
    end

    if sum(valid_frames) == 0
        warning('compute_segsnr: no valid frames found — returning 0 dB.');
        segsnr_db = 0;
        return
    end

    segsnr_db = mean(snr_vals(valid_frames));
end
