# Project Context: CXC-FYP-Griffith

## Academic & Project Identity
- **Project Title**: CXC: Chest X-ray Classifier
- **Author**: Joshan John (Student ID: 3092883)
- **Institution**: Griffith College Dublin (B.Sc. in Computing Science, June 2026)
- **Academic Supervisor**: Jennifer Lebron
- **Full Dissertation Document**: Located at [`docs/thesis-documentation.md`](file:///Users/joshan/dev/CXC-FYP-Griffith/docs/thesis-documentation.md)

## System Overview & Objectives
CXC is an automated clinical decision support system designed to classify chest radiographs into four classes: **Normal**, **Pneumonia**, **Tuberculosis (TB)**, and an out-of-distribution **Unknown** category. The project bridges the gap between deep learning research and real-world clinical usability, addressing global radiologist shortages and prioritizing high diagnostic sensitivity (Recall) to avoid fatal false-negative misdiagnoses.

## Model Progression & Benchmarks

### 1. Custom CNN Models (CXC 100-Series)
- **CXC 101**: Baseline 3-block CNN, $224 \times 224$ input, 11.1M trainable params. Achieved 89.19% test / 88.04% val accuracy, but suffered from training divergence and high TB false negatives.
- **CXC 102**: Tuned via Keras Tuner, $384 \times 384$ input, >104M total params. Experienced over-parameterization; 83.56% test / 85.28% val accuracy, 112 TB false negatives.
- **CXC 103 (Top Custom Model)**: $224 \times 224$ input, Batch Normalization after every conv and dense layer, 16.7M trainable params. Achieved **96.07% test accuracy** and **96.06% val accuracy**. Exceptionally robust on smartphone photos of physical X-ray films.

### 2. Transfer Learning Models (CXC 200-Series)
- **CXC 201 (InceptionV3)**: 89.46% test / 91.20% val accuracy, 79% TB recall.
- **CXC 202 (VGG-16)**: 92.53% test / 94.88% val accuracy, 87% TB recall.
- **CXC 203 (ResNet50 - Champion Model)**: 526,084 trainable params, **97.25% test accuracy**, **98.03% val accuracy**. Achieved **zero false negatives for Pneumonia** (100% recall) and satisfied high clinical safety error thresholds.

## Dataset Specification
- **Total Images**: 21,615 across all splits (Training: 19,327 | Validation: 761 | Test: 1,527).
- **Classes**: Normal, Pneumonia, Tuberculosis, and Unknown (non-medical / non-chest scans to prevent forced false positives).

## Architecture & Code Organization

### Backend (`backend/`)
- **Framework**: Python 3.11+, FastAPI, Uvicorn, TensorFlow 2.16.1.
- **Authentication**: Firebase Authentication JWTs verified at the router level via `api_deps.py` (`get_current_user`).
- **Design Pattern**: Layered Separation of Concerns:
  - `src/api/routers/`: HTTP route handlers (`PredictionRoute.py`, `ModelRoute.py`).
  - `src/api/services/`: Business logic, memory caching of models, batch session tracking (`PredictionService.py`, `ModelService.py`).
  - `src/registry/model/`: Central registry of model metadata, preprocessing routines, and input definitions.
  - `src/utils/`: Shared utilities for image decoding, confusion matrices, and ROC curves.
  - `src/constants/`: Environment configuration loaded from `.env`.
- **Key Features**: In-memory model caching, batch processing with chunking, and downloadable ZIP exports.

### Frontend (`frontend/`)
- **Framework**: Flutter SDK (^3.9.2), Dart.
- **Architecture**: Feature-First (`lib/features/`) structured across `models/`, `views/` (pages and widgets), `controllers/`, and `services/`.
- **Responsiveness**: Centrally managed breakpoints with `LayoutBuilder` adapting across mobile, tablet, and desktop viewports.
- **Navigation**: Persistent state across tabs powered by `MainShell` and `IndexedStack`.
- **Themes**: Full dark mode and light mode support with medical UI styling.
