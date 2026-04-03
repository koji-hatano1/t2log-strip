# t2log-strip 🧠
### The Hatano Skull-Stripping Method (HSS Method) v3.11

**t2log-strip** is a professional utility implementing the **Hatano Skull-Stripping (HSS) Method**. 
It provides a statistical optimization layer for `mri_synthstrip` to ensure high-precision cortical surface preservation.


## 🚀 Overview
**t2log-strip** is an advanced brain masking utility that combines the robust extraction of `mri_synthstrip` with a specialized **Log-Normal Adaptive Thresholding** strategy. 

Developed as **The Hatano Method**, this approach is specifically designed to maximize brain surface protection, ensuring that delicate cortical boundaries are preserved while effectively removing non-brain tissue.

## 📂 HCP Pipeline Integration & Directory Structure
This tool is designed to be integrated into the **HCP Pipeline** (specifically after `PreFreeSurferPipeline.sh`). 
- **Compatibility**: Assumes the standard HCP directory structure.
- **Integration**: When using the generated masks and brain-extracted images in subsequent pipeline stages (e.g., FreeSurfer or PostFreeSurfer), ensure you correctly point to these updated files in your script configurations.

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

## 🔄 Recovery & Undo Process
If you need to revert the changes or test different threshold parameters, use the provided recovery script:

```bash
chmod +x recover_t2ls.sh
./recover_t2ls.sh
```

Note: This script restores the original files from the *_bet.nii.gz backups created during the initial run. It is highly recommended to run this recovery script before re-running t2log-strip.sh with different settings to ensure a clean starting point.

## 🔬 Methodology: The Hatano Skull-Stripping (HSS) Method
While `mri_synthstrip` provides excellent brain extraction, standard thresholding can sometimes be aggressive at the brain-CSF interface. The **Hatano Skull-Stripping (HSS) Method** acts as an optimization layer to refine these boundaries:

1. **Log-Normal Analysis**: Analyzing voxel intensities in log-space to better characterize the brain tissue distribution.
2. **Statistical Refinement**: Applying a 2.576 SD (99% CI) threshold to objectively fine-tune the mask boundaries.
3. **Optimized Surface Preservation**: Specifically tuned to prevent unintended over-stripping of the cortical ribbon, ensuring the integrity of the brain surface for subsequent analysis.


## 🛠 Prerequisites
Ensure the following tools are installed and accessible in your `$PATH`:
- **FSL** (FMRIB Software Library)
- **FreeSurfer** (specifically `mri_synthstrip`)
- **bc** (GNU arbitrary precision calculator)

---
Developed by Koji Hatano. Precision brain masking for professional neuroimaging workflows.
