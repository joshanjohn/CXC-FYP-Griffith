# Project Context: CXC-FYP-Griffith

## Overview
Chest X-Ray Classification (CXC) system for Griffith BSCH Final Year Project (FYP-3092883). Merged from separate organization repositories into a unified monorepo on personal GitHub (`joshanjohn/CXC-FYP-Griffith`).

## Architecture

### 1. Frontend (`frontend/`)
- **Technology**: Flutter / Dart (SDK: ^3.9.2)
- **Primary Package Name**: `cxc`
- **Key Modules**:
  - Image acquisition and validation for Chest X-Rays
  - Firebase authentication integration
  - Interactive prediction and diagnosis display
  - Model selection dropdowns and prediction telemetry
  - Multi-platform support (Web, iOS, Android, macOS, Linux, Windows)

### 2. Backend (`backend/`)
- **Technology**: Python (>=3.11), FastAPI, Uvicorn, TensorFlow 2.16.1, Keras Tuner, Streamlit
- **Package Management**: `uv` / `pyproject.toml`
- **Directory Layout**:
  - `src/api/main.py`: Entrypoint for FastAPI service
  - `src/api/routers/`: API routing (`PredictionRoute.py`, `ModelRoute.py`)
  - `src/api/services/`: Business logic and inference orchestration (`PredictionService.py`, `ModelService.py`)
  - `src/api/middleware/`: Security and dependency injection (`api_deps.py`)
  - `src/registry/model/`: Model metadata, registry, and preprocessing pipelines
  - `src/utils/`: Image preprocessing, ROC curves, confusion matrix generation, and dataset utilities
  - `notebook/`: Exploration, tuning, and training notebooks for binary and multi-class models (e.g. CXC101, CXC102, CXC103, CXC201, CXC202, CXC203, tb_bm)

## Repository History & Maintenance
- **Commit History**: Full commit history from original frontend and backend repositories is preserved with proper subdirectory prefixes.
- **Collaborators**: Configured with collaborator permissions transferred from organization setup.
