# t2log-strip

This tool provides robust brain extraction for T2-weighted images by leveraging **FreeSurfer's `mri_synthstrip`** with log-transformation and statistical standardization preprocessing.

## Overview
While `mri_synthstrip` is a powerful and flexible brain extraction tool, it can occasionally produce unstable results on T2-weighted images due to high-intensity signals from fat/CSF and low-intensity flow voids. 

**t2log-strip** addresses these challenges by applying a robust log-normal standardization. This stabilizes the input for `mri_synthstrip`, ensuring highly precise and reproducible skull stripping tailored for HCP-style T2w datasets.

**Hardware Recommendation:**
For optimal results with minimal geometric distortion in areas such as the **OFC (Orbitofrontal Cortex)** and **TP (Temporal Pole)**, the use of a **16-channel head coil** is highly recommended. 
*(Note: If you are using a **32-channel coil**, please consider using the **t2log-hybrid** method (upcoming release), which is specifically designed for high-density coil profiles.)*

## Optimization Workflow
Parameters should be adjusted based on the **histogram provided in each individual subject's log**.

### 1. Initial `border_num` Selection
In the `# --- Configuration ---` section, set the `border_num` variable:
- **First choice**: Set `border_num=1` for a tighter extraction.
- **Adjustment**: If the **per-subject log** or result shows over-stripping, change to `border_num=2` to preserve more boundary tissue.

### 2. Fine-tuning via `ci_threshold` (Confidence Interval / SD)
After setting `border_num`, use the **histogram in the individual subject's log** to finely tune the `ci_threshold` value. This acts as the **SD (Standard Deviation) factor** to isolate the brain parenchyma from **Flow voids** (low intensity) and **CSF** (high intensity).

- **Goal**: Ensure the brain signal resides within the **second cluster (layer) from the lowest intensity** in the histogram.
- **Adjustment Guide**: 
    - **1.960 (95% CI / SD)**: The standard starting point.
    - **2.241 (97.5% CI / SD)**: For intermediate refinement.
    - **2.576 (99% CI / SD)**: Use this if brain parenchyma is being removed at 1.960.
    - *The value can be adjusted in small increments to perfectly "sandwich" the brain signal between noise and outliers.*

> **Key Tip:** Prioritize "no over-stripping." Refer to the **histogram in your log** and adjust `ci_threshold` until the brain tissue is stably positioned in the second intensity layer.

## Usage

### 1. Setup
Edit the `# --- Configuration ---` section in `t2log-strip.sh` to match your environment:

```bash
# --- Configuration ---
Subjlist="001 002 003"              # Array of Subject IDs to process
BASE_PATH="/path/to/your/project"   # Full path to the project root
border_num=1                        # 1: Tight, 2: Conservative
ci_threshold=1.960                  # 1.960 (95% CI/SD) to 2.576 (99% CI/SD)
```
### 2. Execution
Run the script from your terminal:
```bash
chmod +x t2log-strip.sh
./t2log-strip.sh
```

### 3. Review and Adjust (Iterative Process)
After execution, check the **histogram and processing output in each `$SUBJ_LOG`**.

<img src="./images/report_sample.png" width="400">

1. **Check the Histogram**: Identify the brain parenchyma cluster (the second layer).
2. **Evaluate the Mask**: 
    - **If the brain is over-stripped**: Increase `ci_threshold` (e.g., to 2.576) or change `border_num` to 2.
    - **If too much CSF/Flow void remains**: Decrease `ci_threshold` (e.g., to 1.960) or change `border_num` to 1.
3. **Re-run**: Update the variables in the `# --- Configuration ---` section and execute the script again until the extraction is optimal.

> **Note**: This iterative adjustment ensures the highest precision by accounting for individual variability in T2 intensity distributions and susceptibility artifacts.

### 4. Recovery & Undo Process ###
If you need to revert changes or test different parameters, use the provided recovery script:

```
chmod +x recover_t2ls.sh
./recover_t2ls.sh
```

> [!IMPORTANT]
> - **Configuration**: Ensure `Subjlist` and `BASE_PATH` in `recover_t2ls.sh` match your environment.
> - **Restoration**: Restores original files from the `*_bet.nii.gz` backups created during the initial run.
> - **Clean Start**: Highly recommended to run this recovery script before re-running `t2log-strip.sh` with new parameters.

## HCP Integration
This script is specifically optimized for the **HCP (Human Connectome Project) Pipeline** directory structure, ensuring that the high-precision T2-based mask is propagated across all relevant spaces.

- **T1w Space**: Automatically updates `T1w_acpc_dc_restore_brain.nii.gz` and other T1-weighted images in the `${T1wFolder}` using the new T2-based mask.
- **MNI Space Synchronization**: Synchronizes the updated mask to the **MNINonLinear** folder via `acpc_dc2standard` warps, updating `T1w_restore_brain.nii.gz` and `T2w_restore_brain.nii.gz`.
- **Auto-Backup**: Creates backups of original images (suffix: `_bet.nii.gz`) before applying the new masks, ensuring original data safety.

## QA & Reporting
### Batch Summary (CSV)
A summary file (`hss_t2ls_summary_*.csv`) is automatically generated at the end of the process. This allows for cohort-wide quality assurance by providing:
- **Thresholding Stats**: Min/Max intensity thresholds and SD factors for each subject.
- **Voxel Drop Rates**: Percentage of voxels removed, helping to identify potential over-stripping at a glance.

## Visual Proof: Precision Comparison
<img src="./images/comparison.png" width="400">

- **Background**: `T1w_acpc_dc_restore`
- **Red**: Extraneous non-brain tissue (e.g., **venous sinuses** and **dura**) captured by FSL-BET but **successfully excluded** by t2log-strip.
- **Cyan**: **Restored** brain regions that were previously over-stripped by standard methods.
- **Purple&Green**: **Overlap** where both masks align.

To reproduce this view with **Freeview**, use the provided viewer script:
```bash
# Setup: Set your HCP directory in BASE_PATH within the script.
./fview_t2ls.sh [Subject_ID]
```

## Prerequisites
Ensure these are in your `$PATH`:
- **FSL 6.0.7**
- **FreeSurfer 7.4.1** (`mri_synthstrip`)
- **bc** (GNU calculator)

