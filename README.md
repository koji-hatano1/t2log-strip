# t2log-strip

Robust brain extraction for T2-weighted images using `mri_synthstrip` with log-transform and standardization preprocessing.

## Overview
Brain extraction on T2 images can be unstable due to high-intensity signals from fat or soft tissue. This tool improves `mri_synthstrip` accuracy by applying log-transformation and robust scaling as preprocessing steps.

**Note on Hardware:**  
For optimal results with minimal geometric distortion in the **OFC (Orbitofrontal Cortex)** and **TP (Temporal Pole)**, the use of a **16-channel head coil** is highly recommended. (Note: A separate version for 32-channel coils is planned for future development due to different sensitivity profiles.)

## Optimization Workflow
To achieve the best results, do not rely on fixed parameters. Follow this step-by-step optimization based on your data's histogram.

### 1. Initial `-b` Selection (Start with 1)
First, test the `-b` (outlier threshold) in `mri_synthstrip`:
- **Primary choice**: Start with **`-b 1`** for a tighter extraction.
- **Alternative**: If **`-b 1`** causes over-stripping (removes brain tissue), switch to **`-b 2`** for a more conservative boundary.

### 2. Fine-tuning the SD / Confidence Interval (CI)
Once `-b` is set, adjust the **Standardization threshold** while checking the histogram of the preprocessed image. The CI can be finely tuned (e.g., in 1% increments) to find the optimal balance.

- **Goal**: Ensure the brain signal resides within the **second cluster (layer) from the lowest intensity**.
- **Adjustment Examples**: 
    - **95% CI (approx. 1.960 SD)**: A common starting point.
    - **97.5% CI (approx. 2.241 SD)**: For intermediate adjustment.
    - **99% CI (approx. 2.576 SD)**: Use this if brain tissue is still being over-stripped.

> **Key Tip:** Prioritize "no over-stripping." Finely adjust the CI/SD threshold until the brain parenchyma is stably positioned in the second intensity layer of the histogram.

## 📂 HCP Pipeline Integration
This tool is designed to follow the initial steps of `PreFreeSurferPipeline.sh`.

- **Strategy**: Replaces conservative FSL-BET with a high-fidelity mask that effectively strips persistent non-brain tissues (e.g., **dura and venous sinuses**) while simultaneously **restoring** previously over-stripped brain regions. This eliminates the need for excessive "safety margins" and provides a refined starting point for surface reconstruction.
- **Note**: To fully leverage the potential of this high-fidelity mask, the FreeSurfer process (e.g., `recon-all`) should be appropriately tuned or customized to align with the refined brain-surface input.

## ⚙️ Configuration & Usage
Edit `t2log-strip.sh` to match your environment:
```bash
Subjlist="001 002 003"            # Subject IDs
BASE_PATH="/path/to/project"      # Project root
```

## 🔄 Recovery & Undo Process
If you need to revert changes or test different parameters, use the provided recovery script:

```bash
chmod +x recover_t2ls.sh
./recover_t2ls.sh
```

> [!IMPORTANT]
> - **Configuration**: Ensure `Subjlist` and `BASE_PATH` in `recover_t2ls.sh` match your environment.
> - **Restoration**: Restores original files from the `*_bet.nii.gz` backups created during the initial run.
> - **Clean Start**: Highly recommended to run this recovery script before re-running `t2log-strip.sh` with new parameters.

## 🔬 Methodology: Log-Normal Adaptive Thresholding
While `mri_synthstrip` is robust, applying a T2w-derived mask directly can often capture unwanted non-brain structures due to T2w-specific signal profiles. This tool adds a statistical optimization layer to solve this:

- **Log-Normal Analysis**: Analyzes voxel intensities in log-space for superior tissue characterization, specifically targeting the intensity distribution of the T2w signal.
- **Adaptive Statistical Refinement**: Instead of relying on fixed thresholds, it applies a **1.960 SD (95% CI)** threshold derived from each image's unique distribution to objectively fine-tune boundaries.
- **Dynamic Surface & Cleanup**: Adapts to each scan's intensity profile to prevent over-stripping of the cortical ribbon while effectively stripping persistent outliers like **venous sinuses** and **dura**.
- **Structural Integrity (fillh)**: Finalizes the mask with a **hole-filling (fillh)** process. This prevents potential FreeSurfer errors and surface reconstruction artifacts caused by internal mask voids, ensuring a topologically sound input for `recon-all`.
<img src="./images/report_sample.png" width="400">

## 📊 Visual Proof: Precision Comparison
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

## 🛠 Prerequisites
Ensure these are in your `$PATH`:
- **FSL 6.0.7**
- **FreeSurfer 7.4.1** (`mri_synthstrip`)
- **bc** (GNU calculator)

