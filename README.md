# t2log-strip (v3.11)
**T2w-based SynthStrip with Log-Normal Adaptive Thresholding**

t2log-strip is a high-precision brain masking utility designed for the HCP Pipeline. It optimizes `mri_synthstrip` using a statistical Log-Normal strategy to maximize cortical surface preservation.

## 🚀 Key Features
- **Statistical Refinement**: Uses a 99% CI (2.576 SD) threshold in log-space to refine brain boundaries.
- **Elite Pre-processing**: Provides cleaner input for FreeSurfer, minimizing segmentation errors and protecting the cortical ribbon.
- **HCP Ready**: Seamlessly integrates with the standard HCP directory structure.

## 📂 HCP Pipeline Integration
This tool is designed to follow the initial steps of `PreFreeSurferPipeline.sh`.

- **Strategy**: Replaces conservative FSL-BET with a high-fidelity mask, avoiding the need for excessive margins.
- **Note**: Applying this mask requires appropriate tuning of the FreeSurfer process to align with the refined input.

## ⚙️ Configuration & Usage
Edit `t2log-strip.sh` to match your environment:
```bash
Subjlist="306 310"                # Subject IDs
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
While `mri_synthstrip` is robust, standard thresholding can be aggressive. This tool adds a statistical optimization layer:

- **Log-Normal Analysis**: Analyzes voxel intensities in log-space for better tissue characterization.
- **Statistical Refinement**: Applies a **2.576 SD (99% CI)** threshold to fine-tune boundaries.
- **Surface Preservation**: Prevents over-stripping of the cortical ribbon, ensuring the integrity of the brain surface.

## 📊 Visual Proof: Precision Comparison
<img src="./images/comparison.png" width="400">

- **Background**: `T1w_acpc_dc_restore`
- **Red (FSL-BET)**: Extraneous tissue (e.g., **venous sinuses**) successfully excluded.
- **Blue (t2log-strip)**: **Restored** brain regions that were previously over-stripped.
- **Purple**: **Overlap** where both methods align.

## 🛠 Prerequisites
Ensure these are in your `$PATH`:
- **FSL 6.0.7**
- **FreeSurfer 7.4.1** (`mri_synthstrip`)
- **bc** (GNU calculator)

