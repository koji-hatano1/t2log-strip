#!/bin/bash

# --- Configuration ---
# Set the path to your HCP study directory below.
BASE_PATH="/path/to/your/project"

# Argument check
if [ $# -lt 1 ]; then
    echo "Usage: fview_t2ls.sh [Subject ID]"
    echo "Example: fview_t2ls.sh 001"
    echo ""
    echo "Note: Please ensure the HCP study folder path is set in BASE_PATH within this script."
    echo "Current BASE_PATH: ${BASE_PATH}"
    exit 1
fi

SUBJ=$1
T1wFolder="${BASE_PATH}/${SUBJ}/T1w"

# File existence check
if [ ! -f "${T1wFolder}/T1w_acpc_dc_restore.nii.gz" ]; then
    echo "Error: Files for ${SUBJ} not found."
    exit 1
fi

echo "--- Launching Freeview: Session ${SUBJ} ---"
echo "Layer 1 (Bottom): T1w_acpc_dc_restore (Gray)"
echo "Layer 2 (Middle): Original BET (_bet) [Colormap: Heat, Opacity: 1.0]"
echo "Layer 3 (Top)   : New Auto-Hist [Colormap: Jet, Opacity: 0.5]"

# Freeview execution command
freeview -v \
  "${T1wFolder}/T1w_acpc_dc_restore.nii.gz" \
  "${T1wFolder}/T1w_acpc_dc_restore_brain_bet.nii.gz:colormap=heat:opacity=1.0" \
  "${T1wFolder}/T1w_acpc_dc_restore_brain.nii.gz:colormap=jet:opacity=0.5" &
