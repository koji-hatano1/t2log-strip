# t2log-strip

This tool provides robust T2-weighted brain extraction using FreeSurfer’s `mri_synthstrip`, enhanced with log-transformation and statistical thresholding.

---

## Overview

While `mri_synthstrip` is a powerful and flexible brain extraction tool, it can produce unstable results on T2-weighted images due to high-intensity signals (fat/CSF) and low-intensity flow voids.

**t2log-strip** addresses these issues by applying log-based standardization, enabling stable and reproducible skull stripping tailored for HCP-style T2w datasets.

---

## Hardware Note

Performance may vary depending on acquisition conditions.  
For high-density coil acquisitions (e.g., 32-channel), increased T2-weighted signal instability may affect mask consistency.

---

## Optimization Workflow

Parameters should be adjusted based on the histogram provided in each subject log.

### 1. Initial `border_num` Selection

In the `# --- Configuration ---` section:

- `border_num=1`: tighter extraction  
- `border_num=2`: more conservative (use if over-stripping occurs)

---

### 2. Fine-tuning via `SD_FACTOR_T2`

Use the histogram in the subject log to adjust `SD_FACTOR_T2` (SD-based thresholding):

- **1.960 (95%)**: standard starting point  
- **2.241 (97.5%)**: intermediate  
- **2.576 (99%)**: conservative (use if brain tissue is removed)

👉 Goal: keep brain signal within the second intensity cluster.

> **Tip:** prioritize avoiding over-stripping.

---

## Usage

### 1. Setup

Edit the configuration in `t2log-strip.sh`:

```bash
# --- Configuration ---
Subjlist="001 002 003"
BASE_PATH="/path/to/your/project"
border_num=1
SD_FACTOR_T2=1.960
```
### 2. Execution

```bash
chmod +x t2log-strip.sh
./t2log-strip.sh
```

### 3. Review and Adjust

After execution:

1. Check the histogram in `$SUBJ_LOG`
2. Evaluate mask quality
3. Adjust parameters if needed
4. Re-run until optimal

<img src="./images/report_sample.png" width="400">

- **If the brain is over-stripped**: increase `SD_FACTOR_T2` (e.g., to 2.576) or set `border_num=2`
- **If non-brain tissue remains**: decrease `SD_FACTOR_T2` (e.g., to 1.960) or set `border_num=1`

> **Tip:** Prioritize avoiding over-stripping. Adjust parameters so that brain tissue remains stable within the second intensity cluster.

## Recovery

```bash
chmod +x recover_t2ls.sh
./recover_t2ls.sh
```

- Restores original files from `_bet.nii.gz`
- Recommended before re-running with new parameters

---

## HCP Integration

Designed for HCP pipeline structure:

- Updates T1w and T2w brain images
- Synchronizes masks to MNINonLinear space
- Applies transforms automatically
- Creates backups before modification

---

## QA & Reporting

A summary CSV (`hss_t2ls_summary_*.csv`) is generated:

- intensity thresholds
- SD factors
- voxel drop rates

👉 Useful for cohort-level QA.

---

## Visual Comparison

<img src="./images/comparison.png" width="400">

- **Red**: non-brain tissue removed
- **Cyan**: restored brain regions
- **Overlap**: agreement

---

## Viewer

```bash
./fview_t2ls.sh [Subject_ID]

## Prerequisites

Ensure the following are available in your `$PATH`:

- FSL 6.0.7  
- FreeSurfer 7.4.1 (`mri_synthstrip`)  
- bc (GNU calculator)
