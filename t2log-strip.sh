#!/bin/bash

# ===================================================================================================
#  SCRIPT:    t2log-strip.sh
#  METHOD:    Hatano Skull Stripping Method (v3.11)
#  STRATEGY:  T2w-based SynthStrip with Log-Normal Adaptive Thresholding (2.576 SD)
#  GITHUB:    https://github.com/koji-hatano1/t2log-strip
# ===================================================================================================

# --- Configuration ---
Subjlist="001 002 003"                     # Array of Subject IDs to process
BASE_PATH="/path/to/your/project" 　　　　　# Full path to the project root

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="hss-t2ls_v3.11_${TIMESTAMP}.log"
ERR_FILE="hss-t2ls_v3.11_${TIMESTAMP}.err"

# Function to output to both terminal and log file
log_info() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" | tee -a "$LOG_FILE"; }
log_err() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] (Session ${SESSION}) $1" | tee -a "$ERR_FILE" | tee -a "$LOG_FILE" >&2; }

log_info "t2log-strip.sh: === Hatano Skull Stripping Method v3.11 Started ==="

for SESSION in ${Subjlist} ; do
    log_info "------------------------------------------------------------"
    log_info " Repairing Session: ${SESSION}"
    
    T1wFolder="${BASE_PATH}/${SESSION}/T1w"
    AtlasSpaceFolder="${BASE_PATH}/${SESSION}/MNINonLinear"
    MASK="${T1wFolder}/T1w_acpc_brain_mask.nii.gz"
    FS_MASK="${T1wFolder}/brainmask_fs.nii.gz"
    MNI_MASK="${AtlasSpaceFolder}/brainmask_fs.nii.gz"

    if [ -f "${T1wFolder}/T2w_acpc_dc_restore.nii.gz" ]; then
        log_info "  Step A: Creating T2w-based synth mask & Log-Normal Auto-Thresholding..."
     
        if mri_synthstrip -i "${T1wFolder}/T2w_acpc_dc_restore.nii.gz" -o "${T1wFolder}/T2w_tmp_brain.nii.gz" -m "${T1wFolder}/T2w_tmp_mask.nii.gz" -b 1 --no-csf >> "$LOG_FILE" 2>&1; then
            
            # --- 1. Statistics Calculation (Log-Normal 2.576 SD) ---
            SD_FACTOR=2.576
            INPUT_BRAIN="${T1wFolder}/T2w_tmp_brain.nii.gz"
            # Get initial voxel count before thresholding
            VOX_PRE=$(fslstats "${INPUT_BRAIN}" -V | awk '{print $1}')
            # Log transformation
            fslmaths "${INPUT_BRAIN}" -log "${T1wFolder}/T2w_log_tmp.nii.gz"
            # Get Mean (M) and StdDev (S) from log-space image
            stats_log=($(fslstats "${T1wFolder}/T2w_log_tmp.nii.gz" -M -S))
            M_L=${stats_log[0]:-0} 
            S_L=${stats_log[1]:-0} 
            # Calculate threshold values using bc (returning to exponential space)
            AUTO_MIN=$(echo "scale=10; e($M_L - ($SD_FACTOR * $S_L))" | bc -l)
            AUTO_MAX=$(echo "scale=10; e($M_L + ($SD_FACTOR * $S_L))" | bc -l)
            # Cleanup intermediate log file
            rm -f "${T1wFolder}/T2w_log_tmp.nii.gz"

            # --- 2. Batch Backup Processing (cp -n: no overwrite) ---
            [ -f "$MASK" ] && cp -n "$MASK" "${MASK%.nii.gz}_bet.nii.gz"
            [ -f "$FS_MASK" ] && cp -n "$FS_MASK" "${FS_MASK%.nii.gz}_bet.nii.gz"
            [ -f "$MNI_MASK" ] && cp -n "$MNI_MASK" "${MNI_MASK%.nii.gz}_bet.nii.gz"
            for img in T1w_acpc_dc_restore T1w_acpc_dc T1w_acpc T2w_acpc_dc_restore T2w_acpc_dc T2w_acpc; do
                [ -f "${T1wFolder}/${img}_brain.nii.gz" ] && cp -n "${T1wFolder}/${img}_brain.nii.gz" "${T1wFolder}/${img}_brain_bet.nii.gz"
            done
            for img in T1w_restore T1w T2w_restore T2w; do
                [ -f "${AtlasSpaceFolder}/${img}_brain.nii.gz" ] && cp -n "${AtlasSpaceFolder}/${img}_brain.nii.gz" "${AtlasSpaceFolder}/${img}_brain_bet.nii.gz"
            done

            # --- 3. Image Processing (Thresholding & Mask Generation) ---
            fslmaths "${INPUT_BRAIN}" -thr "$AUTO_MIN" -uthr "$AUTO_MAX" -bin -fillh "$MASK"
            cp -f "$MASK" "$FS_MASK"
            
            # --- 4. Final Stats Calculation ---
            VOX_THR=$(fslstats "${INPUT_BRAIN}" -l "$AUTO_MIN" -u "$AUTO_MAX" -V | awk '{print $1}')
            VOX_DIFF=$(echo "$VOX_PRE - $VOX_THR" | bc)
            DIFF_PERCENT=$(echo "scale=4; $VOX_DIFF * 100 / $VOX_PRE" | bc -l)
            VOX_POST=$(fslstats "$MASK" -V | awk '{print $1}')

            # --- 5. Terminal and Log Output ---
            {
                echo "------------------------------------------------------------"
                echo "Session: ${SESSION} | Mode: Log-Normal ${SD_FACTOR}SD"
                printf " [Thresholds] Auto-Min: %.2f | Auto-Max: %.2f\n" "$AUTO_MIN" "$AUTO_MAX"
                printf " [Stats] Initial: %d | Dropped: %d voxels (%.2f%%)\n" "$VOX_PRE" "$VOX_DIFF" "$DIFF_PERCENT"
                echo " [Final] Mask Size: $VOX_POST voxels"
            } | tee -a "$LOG_FILE"

            # Visual Histogram (Logged only to keep terminal clean)
            {
                echo "--- Visual Histogram (x: Out of Threshold | *: In) ---"
                fslstats "${INPUT_BRAIN}" -h 40 | tail -n +2 | \
                awk -v low="$AUTO_MIN" -v high="$AUTO_MAX" '
                {
                    val = (NR * 1000 / 40); printf "%4d: ", val;
                    # Scale set to 5000 to prevent terminal wrapping
                    for(i=0; i<$1/5000; i++) {
                        if (val > high) printf "x"; 
                        else if (val < low) printf "x"; 
                        else printf "*";
                    } print "";
                }'
                echo "------------------------------------------------------------"
            } >> "$LOG_FILE"

            log_info "  Step B: Updating brain-extracted files in T1w folder..."            
            for img in T1w_acpc_dc_restore T1w_acpc_dc T1w_acpc T2w_acpc_dc_restore T2w_acpc_dc T2w_acpc; do
                [ -f "${T1wFolder}/${img}.nii.gz" ] && fslmaths "${T1wFolder}/${img}.nii.gz" -mas "$MASK" "${T1wFolder}/${img}_brain.nii.gz"
            done
        else
            log_err "SynthStrip failed."; continue
        fi
    else
        log_err "Required ACPC files missing."; continue
    fi

    log_info "  Step C: Synchronizing to MNI space..."
    if applywarp --rel --interp=nn -i "$MASK" -r "${AtlasSpaceFolder}/T1w_restore.nii.gz" \
      -w "${AtlasSpaceFolder}/xfms/acpc_dc2standard.nii.gz" -o "${MNI_MASK}_new.nii.gz" >> "$LOG_FILE" 2>&1; then
        mv -f "${MNI_MASK}_new.nii.gz" "$MNI_MASK"
        for img in T1w_restore T1w T2w_restore T2w; do
            [ -f "${AtlasSpaceFolder}/${img}.nii.gz" ] && fslmaths "${AtlasSpaceFolder}/${img}.nii.gz" -mas "$MNI_MASK" "${AtlasSpaceFolder}/${img}_brain.nii.gz"
        done
        log_info "  [Done] MNI synchronization complete."
    else
        log_err "applywarp failed."
    fi
    log_info " Finished Session: ${SESSION}"
done

# ===================================================================================================
#  Hatano Skull Stripping Method: Auto-Summary Generator
# ===================================================================================================
SUMMARY_FILE="hss_summary_${TIMESTAMP}.csv"

# CSV Header with requested columns
echo "Session,Auto-Min,Auto-Max,Initial-Voxels,Dropped-Voxels,Dropped-Percent,Final-Mask-Size" > "$SUMMARY_FILE"

for SESSION in ${Subjlist} ; do
    # Extract values from the log file using grep/awk
    line=$(grep "Session: ${SESSION} | Mode:" "$LOG_FILE" -A 4)
    
    a_min=$(echo "$line" | grep "Auto-Min" | awk -F': ' '{print $2}' | awk -F' |' '{print $1}')
    a_max=$(echo "$line" | grep "Auto-Max" | awk -F'| Auto-Max: ' '{print $2}')
    
    # Extract stats using specific keywords defined in Step 5
    v_pre=$(echo "$line" | grep "Initial:" | awk -F'Initial: ' '{print $2}' | awk '{print $1}')
    d_vox=$(echo "$line" | grep "Dropped:" | awk -F'Dropped: ' '{print $2}' | awk '{print $1}')
    d_per=$(echo "$line" | grep "Dropped:" | awk -F'(' '{print $2}' | awk -F'%' '{print $1}')
    f_vox=$(echo "$line" | grep "Final] Mask Size" | awk -F': ' '{print $2}' | awk '{print $1}')
    
    echo "${SESSION},${a_min},${a_max},${v_pre},${d_vox},${d_per},${f_vox}" >> "$SUMMARY_FILE"
done

log_info "------------------------------------------------------------"
log_info " [HSS Summary Created] --> ${SUMMARY_FILE}"
log_info "------------------------------------------------------------"
log_info "t2log-strip.sh: Hatano Skull Stripping Method v3.11 Complete."
