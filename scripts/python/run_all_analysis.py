#!/usr/bin/env python3
"""Convenience runner for the Hormuz Energy Economics replication package.
This script does not replace the R scripts; it documents the reproducibility workflow.
"""
import subprocess
from pathlib import Path

scripts = [
    "scripts/R/01_clean_data.R",
    "scripts/R/02_event_study.R",
    "scripts/R/03_panel_models.R",
    "scripts/R/04_robustness.R",
    "scripts/R/05_unit_root_tests.R",
]

for script in scripts:
    print(f"\n=== Running {script} ===")
    subprocess.run(["Rscript", script], check=True)

print("\nAll analysis scripts completed.")
