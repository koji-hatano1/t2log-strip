#!/bin/bash

# ===================================================================================================
#  SCRIPT:    recover_t2ls_v311.sh
#  PROJECT:   t2log-strip (Hatano Skull Stripping Method v3.11)
#  STRATEGY:  Universal Recovery - Restore *_bet.nii.gz & Cleanup v3.11 Artifacts
# ===================================================================================================

# --- Configuration ---
Subjlist="001 002 003"
BASE_PATH="/path/to/your/project"

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="recovery_t2ls_v311_${TIMESTAMP}.log"

# Function to output to both terminal and log file
log_info() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" | tee -a "$LOG_FILE"; }

log_info "=== t2log-strip v3.11: Universal Recovery Process Started ==="

for SESSION in ${Subjlist} ; do
    log_info "------------------------------------------------------------"
    log_info " Restoring Session: ${SESSION}"
    
    T1wFolder="${BASE_PATH}/${SESSION}/T1w"
    AtlasSpaceFolder="${BASE_PATH}/${SESSION}/MNINonLinear"

    # --- Step 1: Universal Restore Logic ---
    for target_dir in "$T1wFolder" "$AtlasSpaceFolder"; do
        if [ -d "$target_dir" ]; then
            log_info "  Checking directory: $target_dir"
            
            for backup in "${target_dir}"/*_bet.nii.gz; do
                if [ -f "$backup" ]; then
                    # Determine original filename by removing "_bet" suffix
                    original="${backup%_bet.nii.gz}.nii.gz"
                    log_info "    Restoring: $(basename "$original")"
                    
                    rm -f "$original"
                    mv -f "$backup" "$original"
                fi
            done
        fi
    done

    # --- Step 2: Cleanup v3.11 Intermediate Artifacts ---
    log_info "  Cleaning up temporary files for ${SESSION}..."
    # Cleanup SynthStrip and Log-Normal temporary files
    rm -f "${T1wFolder}/T2w_tmp_brain.nii.gz"
    rm -f "${T1wFolder}/T2w_tmp_mask.nii.gz"
    rm -f "${T1wFolder}/T2w_log_tmp.nii.gz"
    # Cleanup MNI synchronization artifacts
    rm -f "${AtlasSpaceFolder}/tmp_m.nii.gz"

    log_info " Finished Recovery for Session: ${SESSION}"
done

log_info "------------------------------------------------------------"
log_info " Recovery Complete. All detected backups have been restored."
log_info "------------------------------------------------------------"
