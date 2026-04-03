#!/bin/bash

# ===================================================================================================
#  SCRIPT:    recover_t2ls.sh
#  PROJECT:   t2log-strip (The Hatano Method)
#  STRATEGY:  Undo Process - Restore *_bet.nii.gz to Original Names & Cleanup
# ===================================================================================================

# --- Configuration ---
Subjlist="306 310"                         # Array of Subject IDs to recover
BASE_PATH="/path/to/your/project" # Full path to the project root

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="recovery_t2ls_${TIMESTAMP}.log"

# Function to output to both terminal and log file
log_info() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" | tee -a "$LOG_FILE"; }

log_info "=== t2log-strip: Recovery Process (The Hatano Method) Started ==="

for SESSION in ${Subjlist} ; do
    log_info "------------------------------------------------------------"
    log_info " Restoring Session: ${SESSION}"
    
    T1wFolder="${BASE_PATH}/${SESSION}/T1w"
    AtlasSpaceFolder="${BASE_PATH}/${SESSION}/MNINonLinear"

    # --- 1. Restore Mask Files ---
    for m in "T1w_acpc_brain_mask" "brainmask_fs"; do
        if [ -f "${T1wFolder}/${m}_bet.nii.gz" ]; then
            log_info "  Restoring ${m}.nii.gz from *_bet backup..."
            rm -f "${T1wFolder}/${m}.nii.gz"      # Delete the processed file
            mv -f "${T1wFolder}/${m}_bet.nii.gz" "${T1wFolder}/${m}.nii.gz" # Restore original
        fi
    done

    # --- 2. Restore ACPC Space Brain-Extracted Images (T1w folder) ---
    log_info "  Restoring T1w/T2w brain-extracted files in T1w folder..."
    for img in T1w_acpc_dc_restore T1w_acpc_dc T1w_acpc T2w_acpc_dc_restore T2w_acpc_dc T2w_acpc; do
        if [ -f "${T1wFolder}/${img}_brain_bet.nii.gz" ]; then
            rm -f "${T1wFolder}/${img}_brain.nii.gz"
            mv -f "${T1wFolder}/${img}_brain_bet.nii.gz" "${T1wFolder}/${img}_brain.nii.gz"
        fi
    done

    # --- 3. Restore MNI Space (Atlas) Files (MNINonLinear folder) ---
    log_info "  Restoring Atlas files in MNINonLinear folder..."
    
    # Restore brainmask_fs in Atlas space
    if [ -f "${AtlasSpaceFolder}/brainmask_fs_bet.nii.gz" ]; then
        rm -f "${AtlasSpaceFolder}/brainmask_fs.nii.gz"
        mv -f "${AtlasSpaceFolder}/brainmask_fs_bet.nii.gz" "${AtlasSpaceFolder}/brainmask_fs.nii.gz"
    fi
    
    # Restore brain-extracted images in Atlas space
    for img in T1w_restore T1w T2w_restore T2w; do
        if [ -f "${AtlasSpaceFolder}/${img}_brain_bet.nii.gz" ]; then
            rm -f "${AtlasSpaceFolder}/${img}_brain.nii.gz"
            mv -f "${AtlasSpaceFolder}/${img}_brain_bet.nii.gz" "${AtlasSpaceFolder}/${img}_brain.nii.gz"
        fi
    done

    # --- 4. Cleanup Temporary Files ---
    log_info "  Cleaning up temporary SynthStrip files..."
    rm -f "${T1wFolder}/T2w_tmp_brain.nii.gz" "${T1wFolder}/T2w_tmp_mask.nii.gz"

    log_info " Finished Recovery for Session: ${SESSION}"
done

log_info "------------------------------------------------------------"
log_info " Recovery Complete. All files restored to pre-t2log-strip state."
log_info "------------------------------------------------------------"
