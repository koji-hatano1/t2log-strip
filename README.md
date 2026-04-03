# t2log-strip 🧠
[![Version](https://shields.io)](#)
[![Method](https://shields.io)](#)
[![License](https://shields.io)](#)

A high-precision brain masking tool implementing **The Hatano Method (v3.11)**.

## 🚀 Overview
**t2log-strip** is an advanced brain masking utility that combines the robust extraction of `mri_synthstrip` with a specialized **Log-Normal Adaptive Thresholding** strategy. 

Developed as **The Hatano Method**, this approach is specifically designed to maximize brain surface protection, ensuring that delicate cortical boundaries are preserved while effectively removing non-brain tissue.

## ⚙️ Configuration
To use this script, edit the following lines in `t2log-strip.sh` to match your environment:

```bash
# --- Configuration ---
Subjlist="306 310"                         # Array of Subject IDs to process
BASE_PATH="/path/to/your/project"          # Full path to the project root
```

## 📊 Summary Output (CSV)
For every session, the script generates a comprehensive CSV report:
- **Initial-Voxels**: Voxel count before thresholding.
- **Dropped-Voxels**: Exact number of voxels removed by the Hatano Method.
- **Dropped-Percent**: Percentage of removal (Quality Control metric).
- **Final-Mask-Size**: Resulting mask volume in voxels.

## 🔬 Methodology: The Hatano Method
Traditional thresholding often fails at the brain-CSF interface. The **Hatano Method** improves this by:
1. **Log-Transformation**: Converting voxel intensities into log-space to normalize the distribution.
2. **Adaptive Thresholding**: Applying a 2.576 SD (99% Confidence Interval) threshold.
3. **Surface Protection**: Specifically tuned to prevent over-stripping of the cortical ribbon.

## 🛠 Prerequisites
Ensure the following tools are installed and accessible in your `$PATH`:
- **FSL** (FMRIB Software Library)
- **FreeSurfer** (specifically `mri_synthstrip`)
- **bc** (GNU arbitrary precision calculator)

---
Developed by Koji Hatano. Precision brain masking for professional neuroimaging workflows.
