# CXC-FYP-Griffith

Chest X-Ray Classification (CXC) Final Year Project for Griffith BSCH FYP.

This repository is a unified monorepo consolidating the frontend client application and backend machine learning inference services into a single codebase while preserving full historical commits and version history.

## Repository Structure

```text
CXC-FYP-Griffith/
├── frontend/    # Flutter client application for Chest X-Ray Classification
└── backend/     # FastAPI machine learning inference, model registry, and training notebooks
```

## Projects Overview

### Frontend
- **Framework**: Flutter / Dart
- **Role**: User-facing cross-platform client for capturing/uploading chest X-rays, model selection, visualization, and prediction results.
- **Path**: [`frontend/`](file:///Users/joshan/dev/CXC-FYP-Griffith/frontend)

### Backend
- **Framework**: Python, FastAPI, TensorFlow, Keras Tuner, Streamlit
- **Role**: REST APIs for prediction, model registry, authentication middleware, and model training/evaluation notebooks.
- **Path**: [`backend/`](file:///Users/joshan/dev/CXC-FYP-Griffith/backend)
