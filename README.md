# t2log-strip (v3.11)
**T2w-based SynthStrip with Log-Normal Adaptive Thresholding**

t2log-strip is a high-precision brain masking utility designed for the HCP Pipeline. It optimizes `mri_synthstrip` using a statistical Log-Normal strategy to maximize cortical surface preservation.

## 🚀 Key Features
- **Statistical Refinement**: Uses a 99% CI (2.576 SD) threshold in log-space to refine brain boundaries.
- **Elite Pre-processing**: Provides cleaner input for FreeSurfer, minimizing segmentation errors and protecting the cortical ribbon.
- **HCP Ready**: Seamlessly integrates with the standard HCP directory structure.
- **Aggressive Cleanup**: Effectively strips away persistent non-brain tissues like **venous sinuses** and dura that often contaminate the standard mask.

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
- **Adaptive Statistical Refinement**: Instead of relying on fixed thresholds that might fail across different scans, it applies a **2.576 SD (99% CI)** threshold derived from each image's unique distribution to objectively fine-tune boundaries.
- **Dynamic Surface & Cleanup**: Adapts to each scan's intensity profile to prevent over-stripping of the cortical ribbon, while effectively stripping persistent outliers like **venous sinuses** and **dura** that standard T2w-masking often misses.

## 📊 Visual Proof: Precision Comparison
<img src="./images/comparison.png" width="400">

- **Background**: `T1w_acpc_dc_restore`
- **Red**: Extraneous non-brain tissue (e.g., **venous sinuses** and **dura**) captured by FSL-BET but **successfully excluded** by t2log-strip.
- **Blue**: **Restored** brain regions that were previously over-stripped by standard methods.
- **Purple**: **Overlap** where both masks align.

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

