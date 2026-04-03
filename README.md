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
