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
