# CXC: Chest X-ray Classifier

[![Degree](https://img.shields.io/badge/Degree-B.Sc.%20Computing%20Science-blue)](https://www.griffith.ie/)
[![Institution](https://img.shields.io/badge/Institution-Griffith%20College%20Dublin-red)](https://www.griffith.ie/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.11%2B-blue)](https://www.python.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.9.2%2B-02569B?logo=flutter)](https://flutter.dev/)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-2.16.1-FF6F00?logo=tensorflow)](https://www.tensorflow.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.135%2B-009688?logo=fastapi)](https://fastapi.tiangolo.com/)

An end-to-end clinical support system and deep learning pipeline designed to automatically classify chest radiographs into **Normal**, **Pneumonia**, **Tuberculosis (TB)**, and an out-of-distribution **Unknown** category to assist triage and combat radiologist shortages.

Developed as a Final Year Project / Dissertation by **Joshan John** (Student ID: 3092883) for the degree of **B.Sc. in Computing Science** at **Griffith College Dublin**, under the academic supervision of **Jennifer Lebron**.

For the complete dissertation text, methodology, mathematical formulations, and literature review, see [docs/thesis-documentation.md](file:///Users/joshan/dev/CXC-FYP-Griffith/docs/thesis-documentation.md).

---

## 📌 Executive Summary

Radiology services face significant global strain. According to the EU-REST project, imaging demand is projected to surge by 70% by 2030, while radiologist headcounts grow at only ~1% annually. CXC addresses this bottleneck by providing a rapid, dependable, and cross-platform diagnostic assistant.

### Key Achievements
- **Robust 4-Class Classification**: Formulated with an **Unknown** class (19,327 total images) to reject non-radiological inputs and prevent false disease attributions.
- **Top Transfer Learning Model (CXC 203 - ResNet50)**:
  - **97.25%** Test Accuracy | **98.03%** Validation Accuracy
  - **Zero false negatives for Pneumonia** (100% recall), critical for patient safety.
- **Top Custom CNN Model (CXC 103)**:
  - **96.07%** Test Accuracy | **96.06%** Validation Accuracy
  - Incorporates per-block Batch Normalization, remaining robust even on ambient smartphone photographs of physical X-ray films.
- **Production Backend**: Built on FastAPI with Firebase Authentication JWT middleware, in-memory model caching, and multi-image batch inference with ZIP export.
- **Cross-Platform Client**: Built on Flutter & Dart utilizing a Feature-First modular structure, adaptive `LayoutBuilder` breakpoints, and `IndexedStack` state preservation.

---

## 🔬 Model Performance & Evaluation

The models were evaluated against strict clinical criteria, prioritizing **Recall (Sensitivity)** to eliminate fatal false-negative misclassifications where infectious conditions are diagnosed as healthy.

| Model Alias | Architecture | Input Shape | Trainable Parameters | Test Accuracy | Validation Accuracy | Clinical Error Threshold |
|:---|:---|:---:|:---:|:---:|:---:|:---:|
| **CXC 101** | Custom CNN (3-block baseline) | $224 \times 224$ | 11,169,482 | 89.19% | 88.04% | Low (Divergence issues) |
| **CXC 102** | Custom CNN + Keras Tuner | $384 \times 384$ | ~34,700,000 | 83.56% | 85.28% | Low (112 TB False Negatives) |
| **CXC 103** | **Custom CNN + Block BatchNorm** | $224 \times 224$ | **16,745,028** | **96.07%** | **96.06%** | **Medium (Robust on photo scans)** |
| **CXC 201** | InceptionV3 Transfer | $224 \times 224$ | 526,084 | 89.46% | 91.20% | Low (79% TB Recall) |
| **CXC 202** | VGG-16 Transfer | $224 \times 224$ | ~526,000 | 92.53% | 94.88% | Medium (87% TB Recall) |
| **CXC 203** | **ResNet50 Transfer (Champion)** | $224 \times 224$ | **526,084** | **97.25%** | **98.03%** | **High (0 Pneumonia Misses)** |

---

## 📊 Dataset Distribution

The dataset combines multi-source radiological repositories with an engineered **Unknown** class of non-medical imagery to guarantee out-of-distribution detection:

| Partition | Normal | Pneumonia | Tuberculosis | Unknown | Total |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Train** | 6,083 | 6,165 | 5,924 | 1,155 | **19,327** |
| **Validation** | 274 | 213 | 207 | 67 | **761** |
| **Test** | 548 | 427 | 417 | 135 | **1,527** |

---

## 🏗️ Repository Architecture

This repository is unified as a monorepo containing both client and server subsystems:

```text
CXC-FYP-Griffith/
├── docs/
│   └── thesis-documentation.md    # Complete academic dissertation text & figures
├── frontend/                      # Flutter client application
│   ├── lib/
│   │   ├── features/              # Feature-first modules (auth, home, docs, batch)
│   │   │   └── <feature>/
│   │   │       ├── models/        # Immutable data models
│   │   │       ├── views/         # Pages and reusable widgets
│   │   │       ├── controllers/   # Component business logic
│   │   │       └── services/      # API communication & local hardware
│   │   ├── core/                  # Navigation shell, responsive helpers, theme
│   │   └── main.dart              # Application entrypoint
│   └── pubspec.yaml
└── backend/                       # FastAPI prediction & training service
    ├── src/
    │   ├── api/
    │   │   ├── main.py            # FastAPI entrypoint
    │   │   ├── routers/           # PredictionRoute.py, ModelRoute.py
    │   │   ├── services/          # PredictionService.py, ModelService.py
    │   │   └── middleware/        # Firebase JWT bearer token dependency
    │   ├── registry/model/        # Model definitions, metadata, and preprocessing
    │   ├── utils/                 # Image utilities, ROC, confusion matrix tools
    │   └── constants/             # Centralized settings and variables
    ├── notebook/                  # Training & experimentation notebooks (CXC 101 - CXC 203)
    └── pyproject.toml             # Python package dependencies (managed with uv)
```

---

## 🔌 API Endpoints Reference

The FastAPI service exposes auto-documented REST endpoints secured with Firebase JWT Bearer tokens:

| Method | Endpoint | Description |
|:---|:---|:---|
| `GET` | `/health` | Service liveness probe |
| `GET` | `/models` | Returns active model aliases |
| `GET` | `/get_model_info` | Metadata, layer counts, parameters, and training metrics from registry |
| `POST` | `/predict` | Classifies a single chest X-ray and returns class probabilities |
| `POST` | `/batch/start` | Creates a new isolated batch session ID for multi-file processing |
| `POST` | `/predict/batch` | Bulk inference stream for uploaded scans |
| `GET` | `/batch/download` | Bundles segregated classified images into a downloadable ZIP |

---

## 🚀 Getting Started

### 1. Prerequisites
- **Python**: `>= 3.11` (with `uv` or `pip`)
- **Flutter**: `>= 3.9.2`
- **Firebase Project**: Configured for Web, iOS, or Android authentication

### 2. Backend Setup
```bash
cd backend
# Install dependencies using uv
uv sync
# Or install using pip
pip install -e .

# Configure environment variables (.env)
cp .example.env .env

# Run FastAPI server
uvicorn src.api.main:app --host 0.0.0.0 --port 8000 --reload
```
Swagger UI will be accessible at `http://localhost:8000/docs`.

### 3. Frontend Setup
```bash
cd frontend
# Fetch Flutter dependencies
flutter pub get

# Run on your target platform (Chrome, macOS, iOS simulator, Android emulator)
flutter run -d chrome
```

---

## 📜 Academic Citation

If you use or build upon this research or codebase, please cite:

```bibtex
@thesis{john2026cxc,
  author       = {Joshan John},
  title        = {CXC: Chest X-ray Classifier},
  school       = {Griffith College Dublin},
  year         = {2026},
  month        = {June},
  note         = {Supervised by Jennifer Lebron}
}
```

## 📄 License
This project is licensed under the [MIT License](LICENSE).
