# EC-313 Digital Signal Processing — CEP Project
## Speech Enhancement for Airport Noise Suppression (NOIZEUS Corpus)

> **Group Members:** Ibrahim · Shaheer · A.  
> **Submission Format:** MATLAB `.m` files + `.fig`/`.png` figures + IEEE report (`.docx`)  
> **Dataset:** NOIZEUS corpus — airport noise, 5 dB SNR, 8 kHz  

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [File Inventory](#2-file-inventory)
3. [How the Files Connect](#3-how-the-files-connect)
4. [Completion Progress Tracker](#4-completion-progress-tracker)
5. [Step-by-Step Running Instructions](#5-step-by-step-running-instructions)
6. [Instructions for Each Team Member](#6-instructions-for-each-team-member)
   - [Ibrahim (Analysis & Metrics)](#ibrahim--analysis--metrics)
   - [Shaheer (Filter Design)](#shaheer--filter-design)
   - [A. (Report & Qualitative Analysis)](#a--report--qualitative-analysis)
7. [What Goes Into the Report](#7-what-goes-into-the-report)
8. [Folder Structure](#8-folder-structure)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Project Overview

The goal is to design and implement a **speech enhancement filter** in MATLAB that reduces airport background noise from speech recordings in the NOIZEUS corpus. The project is evaluated on three axes:

- **Understanding** — Does your filter choice make sense given the noise characteristics?
- **Implementation** — Do your metrics (SegSNR, PESQ, MSE) show genuine improvement?
- **Presentation** — Can you defend every design decision under questioning?

The work is split into three roles that feed into each other in a specific order. **This order matters — do not skip steps or work out of sequence.**

```
Ibrahim  →  Shaheer  →  Ibrahim  →  A.
(baseline)  (filter)    (metrics)   (report)
```

---

## 2. File Inventory

| File | Owner | When to Run | What It Does |
|------|-------|-------------|--------------|
| `ibrahim_analysis.m` | Ibrahim | **First — before anyone else starts** | Loads all 10 NOIZEUS sentences, generates waveform/PSD/spectrogram figures, computes baseline metrics, saves `baseline_metrics.mat` |
| `compute_segsnr.m` | Ibrahim | **Never run directly** — called automatically | Helper function that calculates Segmental SNR using 25 ms frames and Loizou's silence-exclusion method |
| `compute_all_metrics.m` | Ibrahim | **Never run directly** — called automatically | Reusable function that computes SegSNR + PESQ + MSE for any set of signals; used for both baseline and post-filter evaluation |
| `ibrahim_postfilter_eval.m` | Ibrahim | **Last — after Shaheer finishes** | Loads Shaheer's filtered output, runs all metrics, generates 3-panel annotated spectrograms, saves `results_table.mat` |
| `FOR_SHAHEER_filter_interface.m` | Shaheer | **Reference only — do not run as-is** | Template showing Shaheer exactly how to wrap his filter loop and save `enhanced_signals.mat` correctly |

### Files Generated at Runtime (not in the repo yet — they get created when you run the scripts)

| File | Created By | Used By |
|------|-----------|---------|
| `baseline_metrics.mat` | `ibrahim_analysis.m` | `FOR_SHAHEER_filter_interface.m` + `ibrahim_postfilter_eval.m` |
| `enhanced_signals.mat` | Shaheer's filter script | `ibrahim_postfilter_eval.m` |
| `results_table.mat` | `ibrahim_postfilter_eval.m` | A. (for report numbers) |
| `../figures/*.fig` + `*.png` | Both Ibrahim scripts | Report figures folder |

---

## 3. How the Files Connect

The diagram below shows exactly how data flows between scripts and team members:

```
┌─────────────────────────────────────────────────────────────────┐
│  NOIZEUS Dataset                                                │
│  ../noizeus/clean/sp01.wav … sp10.wav                          │
│  ../noizeus/noisy/sp01_airport_sn5.wav … sp10_airport_sn5.wav │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │  ibrahim_analysis.m    │  ← Ibrahim runs this FIRST
              │  (uses compute_segsnr  │
              │   + compute_all_metrics│
              │   internally)          │
              └────────────┬───────────┘
                           │ saves
              ┌────────────▼───────────┐      ┌──────────────────────────┐
              │  baseline_metrics.mat  │      │  ../figures/             │
              │  - clean_signals       │      │  sp01_timedomain.fig/png  │
              │  - noisy_signals       │      │  sp01_psd.fig/png         │
              │  - all_segsnr          │      │  sp01_spectrogram.fig/png │
              │  - all_pesq            │      └──────────────────────────┘
              │  - all_mse             │
              │  - Fs, file_labels     │
              └────────────┬───────────┘
                           │ Shaheer loads this
                           ▼
              ┌────────────────────────┐
              │  Shaheer's filter      │  ← Shaheer writes this script
              │  script (FIR/IIR/etc.) │    using FOR_SHAHEER_filter_
              │  + timing loop from    │    interface.m as a template
              │  FOR_SHAHEER_*.m       │
              └────────────┬───────────┘
                           │ saves
              ┌────────────▼───────────┐
              │  enhanced_signals.mat  │
              │  - enhanced_signals    │
              │  - proc_times          │
              └────────────┬───────────┘
                           │ Ibrahim loads this
                           ▼
              ┌────────────────────────┐
              │ ibrahim_postfilter     │  ← Ibrahim runs this LAST
              │ _eval.m                │
              │ (uses compute_all      │
              │  _metrics.m internally)│
              └────────────┬───────────┘
                    saves  │
          ┌────────────────┴────────────────────┐
          │                                     │
          ▼                                     ▼
┌─────────────────────┐           ┌─────────────────────────────┐
│  results_table.mat  │           │  ../figures/                │
│  All baseline +     │           │  sp01_spectrogram_           │
│  enhanced metrics   │           │  comparison.fig/png          │
│  ready for report   │           │  (clean / noisy / enhanced) │
└─────────────────────┘           └─────────────────────────────┘
          │
          ▼
     A. uses these numbers
     to fill the report table
     and annotate spectrograms
```

---

## 4. Completion Progress Tracker

Use this to track where the project stands. Update it as work is done.

### Phase 1 — Signal Analysis (Ibrahim)
- [ ] NOIZEUS dataset downloaded and folder structure set up
- [ ] `DATA_ROOT` path updated in `ibrahim_analysis.m`
- [ ] `ibrahim_analysis.m` runs end-to-end without errors
- [ ] 3 figures generated per sentence (waveform, PSD, spectrogram)
- [ ] Baseline console table printed (SegSNR, PESQ, MSE)
- [ ] `baseline_metrics.mat` saved and shared with Shaheer

### Phase 2 — Filter Design (Shaheer)
- [ ] `baseline_metrics.mat` received from Ibrahim
- [ ] Filter designed in MATLAB (type decided based on PSD observations)
- [ ] Filter frequency response and group delay plotted and saved as `.fig`
- [ ] Filter applied to all 10 sentences using the loop from `FOR_SHAHEER_filter_interface.m`
- [ ] `enhanced_signals.mat` saved and shared with Ibrahim

### Phase 3 — Post-Filter Evaluation (Ibrahim)
- [ ] `enhanced_signals.mat` received from Shaheer
- [ ] `ibrahim_postfilter_eval.m` runs end-to-end without errors
- [ ] Comparison table printed in console
- [ ] Annotated 3-panel spectrograms saved for all sentences
- [ ] `results_table.mat` saved and shared with A.

### Phase 4 — Report (A.)
- [ ] `results_table.mat` received from Ibrahim
- [ ] System flowchart created
- [ ] Noise characterisation section written (using Ibrahim's PSD observations)
- [ ] Filter design rationale section written (using Shaheer's parameters)
- [ ] Results table filled in from `results_table.mat`
- [ ] Annotated spectrograms embedded and discussed
- [ ] 2022–2024 improvement paper found and cited
- [ ] All 3 mandatory reference papers cited in IEEE format
- [ ] Report formatted in IEEE double-column `.docx`

---

## 5. Step-by-Step Running Instructions

### Prerequisites
- MATLAB with **Signal Processing Toolbox** (mandatory)
- MATLAB **Audio Toolbox** (optional — needed for `pesq()`. Without it, PESQ shows `NaN` but nothing crashes)
- NOIZEUS corpus downloaded from: https://ecs.utdallas.edu/loizou/speech/noizeus/

### Step 1 — Set Up Folder Structure
Organise your files exactly like this before running anything:

```
project_root/
├── noizeus/
│   ├── clean/
│   │   ├── sp01.wav
│   │   ├── sp02.wav
│   │   └── ... (up to sp30.wav)
│   └── noisy/
│       ├── sp01_airport_sn5.wav
│       ├── sp02_airport_sn5.wav
│       └── ...
├── code/                        ← put ALL .m files here
│   ├── ibrahim_analysis.m
│   ├── compute_segsnr.m
│   ├── compute_all_metrics.m
│   ├── ibrahim_postfilter_eval.m
│   ├── FOR_SHAHEER_filter_interface.m
│   └── [Shaheer's filter script].m
└── figures/                     ← created automatically
```

### Step 2 — Update the Data Path (Ibrahim)
Open `ibrahim_analysis.m` and change line 16:
```matlab
DATA_ROOT = '../noizeus';   % change this to wherever your NOIZEUS folder is
```
For example, if your folder is on the Desktop:
```matlab
DATA_ROOT = 'C:/Users/YourName/Desktop/noizeus';  % Windows
DATA_ROOT = '/Users/YourName/Desktop/noizeus';    % Mac
```

### Step 3 — Run Phase 1 (Ibrahim)
In MATLAB:
1. Set your working directory to the `code/` folder: `cd('path/to/code')`
2. Run: `ibrahim_analysis`
3. Expected output: a table in the console + 3 figure windows + `baseline_metrics.mat` saved

```
Loading 10 sentence pairs ...
Loaded 10 valid sentence pairs.

=== Detailed analysis: sp01 ===
  Dominant low-freq noise peak ≈ 180 Hz
  Mean clean PSD in 300–3400 Hz : -32.5 dB/Hz
  Mean noise PSD in 300–3400 Hz : -28.1 dB/Hz (delta = 4.4 dB)

Sentence   SegSNR(dB)      PESQ          MSE
----------------------------------------------
sp01          +3.142       1.823    4.12e-04
...
MEAN          +X.XXX       X.XXX    X.XXXe-XX
```

4. **Share `baseline_metrics.mat` with Shaheer before he starts.**

### Step 4 — Run Phase 2 (Shaheer)
1. Copy `FOR_SHAHEER_filter_interface.m` and read the comments — it tells you exactly what to do
2. Write your filter design script (name it something like `shaheer_filter.m`)
3. At the end of your script, paste the loop from `FOR_SHAHEER_filter_interface.m` and replace the placeholder line with your actual `filter()` call
4. Run your script — it will save `enhanced_signals.mat`
5. **Share `enhanced_signals.mat` with Ibrahim.**

### Step 5 — Run Phase 3 (Ibrahim)
1. Make sure both `baseline_metrics.mat` and `enhanced_signals.mat` are in the `code/` folder
2. Run: `ibrahim_postfilter_eval`
3. Expected output: comparison table in console + `.fig`/`.png` files in `../figures/`
4. **Share `results_table.mat` and the `figures/` folder with A.**

### Step 6 — Write the Report (A.)
Use the numbers in `results_table.mat` and the figures from `../figures/` to fill the report. See [Section 7](#7-what-goes-into-the-report) for exactly what goes where.

---

## 6. Instructions for Each Team Member

---

### Ibrahim — Analysis & Metrics

**Your two scripts:** `ibrahim_analysis.m` (run first) and `ibrahim_postfilter_eval.m` (run last).  
The helper scripts `compute_segsnr.m` and `compute_all_metrics.m` are called automatically — you never run them directly, but **they must be in the same folder** as your main scripts.

**Phase 1 — Before Shaheer starts:**
1. Download NOIZEUS. Set `DATA_ROOT` in `ibrahim_analysis.m`.
2. Run `ibrahim_analysis.m`. Read the console output carefully — it prints observations about dominant noise frequencies and PSD differences. **Write these down or screenshot them and send to A.** — she needs them for the noise characterisation section of the report.
3. Check the 3 figures that open: waveform comparison, PSD overlay, and spectrogram pair. Make sure they look right (the noisy signal should look messier, the PSD of the noisy signal should be higher especially below 300 Hz).
4. Send `baseline_metrics.mat` to Shaheer.

**Phase 3 — After Shaheer finishes:**
1. Put `enhanced_signals.mat` (from Shaheer) in the same folder as your scripts.
2. Run `ibrahim_postfilter_eval.m`.
3. The comparison table it prints is exactly what goes in the report. Send a screenshot + `results_table.mat` to A.
4. The 3-panel spectrogram figures go into `../figures/`. These are what A. annotates in the report.

**Notes:**
- If `pesq()` gives an error, it means your MATLAB doesn't have the Audio Toolbox. The scripts handle this gracefully (PESQ shows `NaN`). In that case, note in the report that PESQ was computed using [alternative method / not available] — A. should mention this as a limitation.
- The `compute_segsnr.m` function clips per-frame SNR to the range [−10, +35] dB, following the method in Loizou (2007). This is the standard approach and matches what the reference papers use.

---

### Shaheer — Filter Design

**Your job:** Design the actual filter, apply it to all 10 sentences, and save the results correctly so Ibrahim can evaluate them.

**Before you start:**
1. Get `baseline_metrics.mat` from Ibrahim and put it in your MATLAB working folder.
2. Open `FOR_SHAHEER_filter_interface.m` — **read the whole file.** It is a template, not a runnable script. Copy the loop structure from it into your own filter script.

**Writing your filter script:**

Your script needs to do three things, in order:
```matlab
% 1. Load Ibrahim's data
load('baseline_metrics.mat');

% 2. Design your filter (FIR / IIR / Notch — your call)
%    e.g.: [b, a] = butter(6, [300 3400]/(Fs/2), 'bandpass');

% 3. Apply it in a timed loop (copy from FOR_SHAHEER_filter_interface.m)
%    Save the output as enhanced_signals.mat
```

**What to document (Shaheer's section of the report):**
- Filter type and why you chose it (FIR vs IIR, order, window if FIR)
- Cutoff frequencies — justify them using Ibrahim's PSD observations (e.g., "PSD analysis showed dominant noise below 300 Hz and above 4 kHz, motivating a bandpass filter at 300–3400 Hz")
- Frequency response plot (magnitude in dB vs Hz) — save as `.fig`
- Phase response and group delay plot — save as `.fig`
- The MATLAB function you used (`fir1`, `butter`, `cheby1`, `ellip`, or `designfilt`)
- All numeric parameters (order, cutoff, ripple, attenuation as applicable)

**After your filter script runs:**
1. Check that `enhanced_signals.mat` was saved.
2. The script plays the original and filtered audio back-to-back — listen and confirm it sounds less noisy.
3. Send `enhanced_signals.mat` to Ibrahim.

---

### A. — Report & Qualitative Analysis

**Your job:** Literature review, system flowchart, methodology, and all written analysis. You don't run MATLAB.

**What you need to collect from your teammates:**
- From Ibrahim (Phase 1): console output showing noise frequency observations + the 3 figure types (waveform, PSD, spectrogram)
- From Shaheer: his filter parameters (type, order, cutoffs, ripple) and his frequency response figures
- From Ibrahim (Phase 3): `results_table.mat` numbers + the 3-panel annotated spectrogram figures

**Report section-by-section guide:**

**Abstract** (~150 words)  
Write last. Summarise the problem (airport noise at 5 dB SNR), the method (whatever filter Shaheer chose), and the key result (SegSNR improved from X to Y dB, PESQ from X to Y).

**1. Introduction & Noise Characterisation**  
Use Ibrahim's PSD observations. Describe what airport noise looks like in the frequency domain: it is non-stationary, has strong low-frequency components from engine rumble (typically below 300 Hz), broadband crowd babble in the mid-range, and occasional impulsive transients. Reference the PSD figure Ibrahim generated. Cite reference [1] (Hu & Loizou, 2007) and reference [3] (Upadhyay et al., 2023) here.

**2. Filter Design Rationale & Parameter Justification**  
Use Shaheer's parameters. Explain *why* the filter type was chosen for this specific noise. Connect the noise characterisation from Section 1 to the filter design decisions. Include Shaheer's frequency response and group delay figures. Reference [2] (Pandey et al., 2022) here.

**3. Results**  
Copy the numbers from `results_table.mat` into the table below. Ibrahim will give you the exact values.

| Metric | Noisy Baseline | Enhanced Output |
|--------|---------------|-----------------|
| Segmental SNR (dB) | [from Ibrahim] | [from Ibrahim] |
| PESQ Score | [from Ibrahim] | [from Ibrahim] |
| Mean Squared Error | [from Ibrahim] | [from Ibrahim] |
| Processing Time / utterance (s) | — | [from Ibrahim] |

Compare your PESQ and SegSNR values to published benchmarks: Pandey et al. [2] report PESQ scores around 1.8–2.3 for classical filter methods on NOIZEUS airport noise. Upadhyay et al. [3] report SegSNR improvements of 2–5 dB depending on method and SNR level. Use these to contextualise whether your results are in a reasonable range.

**4. Spectrogram-Based Qualitative Analysis**  
Use the 3-panel spectrogram figures from Ibrahim. For each panel, annotate and discuss:
- *Clean panel:* formant structure visible as horizontal bands of energy in the 300–3400 Hz range
- *Noisy panel:* broadband noise floor raised across all frequencies; low-frequency energy from engine noise visible below 300 Hz; speech formants harder to distinguish
- *Enhanced panel:* assess whether the noise floor is reduced, whether the speech band is preserved, whether any ringing artefacts are visible (ringing looks like horizontal smearing around sharp transients), whether speech distortion has been introduced

**5. Critical Analysis & Justification**  
Address all four required points from the project spec:
- Are the SegSNR and PESQ improvements practically meaningful at 5 dB input SNR?
- Where does the filter succeed (silence frames, low-frequency suppression) and where does it fail (non-stationary bursts, speech-band noise)?
- Why was this filter type chosen over alternatives?
- One technically feasible modification with a citation from 2022–2024 (see note below)

**Finding the 2022–2024 improvement paper:**  
Search Google Scholar for terms like *"speech enhancement deep learning NOIZEUS 2023"* or *"spectral subtraction airport noise improvement 2022"* or *"Wiener filter speech enhancement NOIZEUS 2024"*. The paper needs to suggest a concrete modification that could improve on classical filter approaches. Good candidate journals: *International Journal of Speech Technology (Springer)*, *Speech Communication (Elsevier)*, *IEEE Signal Processing Letters*. Reference [3] (Upadhyay 2023) is already from this window and may itself suggest improvements — read it.

**6. Conclusion** (~100 words)  
Restate the approach, summarise the quantitative improvement, and note the main limitation and the proposed future improvement.

**System Flowchart:**  
The spec says it must include MATLAB function names at each step. Use this structure:

```
[audioread()] → Clean Signal
[audioread()] → Noisy Signal
       ↓
[pwelch(), spectrogram()] → Signal Analysis & Noise Characterisation
       ↓
[butter()/fir1()/etc.] → Filter Design
       ↓
[filter()] → Apply Filter to Noisy Signal → Enhanced Signal
       ↓
[compute_segsnr()] → Segmental SNR
[pesq()]           → PESQ Score        → Results Table
[mse computation]  → MSE
       ↓
[spectrogram()] → Comparative Spectrogram Figures
```

Create this as a proper box-and-arrow diagram in Word or draw.io and embed it in the report.

---

## 7. What Goes Into the Report

Quick reference mapping from script outputs to report sections:

| Script Output | Report Section | Who Adds It |
|---|---|---|
| `sp01_timedomain.png` | Section 1 (Introduction) | A. |
| `sp01_psd.png` | Section 1 (Introduction) | A. |
| `sp01_spectrogram.png` | Section 1 (Introduction) | A. |
| Shaheer's frequency response `.fig` | Section 2 (Filter Design) | A. (Shaheer provides the file) |
| Shaheer's group delay `.fig` | Section 2 (Filter Design) | A. |
| Console table from `ibrahim_postfilter_eval.m` | Section 3 (Results Table) | A. (Ibrahim provides the numbers) |
| `sp01_spectrogram_comparison.png` | Section 4 (Qualitative Analysis) | A. |
| 2022–2024 journal paper | Section 5 (Critical Analysis) | A. |

---

## 8. Folder Structure

This is the expected layout. Keep it clean.

```
project_root/
│
├── noizeus/
│   ├── clean/          ← sp01.wav … sp30.wav
│   └── noisy/          ← sp01_airport_sn5.wav … sp30_airport_sn5.wav
│
├── code/
│   ├── ibrahim_analysis.m          ← Ibrahim: run FIRST
│   ├── compute_segsnr.m            ← helper (never run directly)
│   ├── compute_all_metrics.m       ← helper (never run directly)
│   ├── ibrahim_postfilter_eval.m   ← Ibrahim: run LAST
│   ├── FOR_SHAHEER_filter_interface.m  ← Shaheer: read and copy from
│   ├── [shaheer_filter].m          ← Shaheer: writes this
│   ├── baseline_metrics.mat        ← generated by ibrahim_analysis.m
│   ├── enhanced_signals.mat        ← generated by Shaheer's script
│   └── results_table.mat           ← generated by ibrahim_postfilter_eval.m
│
├── figures/
│   ├── sp01_timedomain.fig / .png
│   ├── sp01_psd.fig / .png
│   ├── sp01_spectrogram.fig / .png
│   └── sp01_spectrogram_comparison.fig / .png   ← one set per sentence
│
└── report/
    └── [group_report].docx
```

---

## 9. Troubleshooting

**`audioread` can't find the file**  
→ Check that `DATA_ROOT` in `ibrahim_analysis.m` points to the right place. Use an absolute path if a relative path isn't working.

**`pesq()` throws an error**  
→ You don't have the Audio Toolbox. All PESQ entries will show `NaN`. Note this in the report — it is not a code error. If you can access the ITU P.862 binary separately, ask Ibrahim to integrate it.

**`load('baseline_metrics.mat')` fails in Shaheer's script**  
→ The `.mat` file must be in MATLAB's current working directory. Either move it to the `code/` folder or add the path: `addpath('path/to/folder/with/mat/file')`.

**`enhanced_signals.mat` not found when Ibrahim runs Phase 3**  
→ Shaheer's script didn't save it, or it was saved to a different folder. Check that the save line ran without error and that the file is in the `code/` folder.

**Figures look blank or axes are empty**  
→ The signal is likely all zeros. Check that the `.wav` files loaded correctly by printing `max(abs(x_clean))` — it should be roughly 0.1–0.9.

**SegSNR improvement is negative**  
→ This means the filter is making things worse (adding distortion in the speech band). Shaheer needs to re-examine the cutoff frequencies.

---

*Dataset citation (mandatory in report): Hu, Y. and Loizou, P. (2007). Subjective evaluation and comparison of speech enhancement algorithms. Speech Communication, vol. 49, pp. 588–601.*
