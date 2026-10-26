# CXC: Chest X-ray Classifier 🫁

[![Degree](https://img.shields.io/badge/Degree-B.Sc.%20Computing%20Science-blue)](https://www.griffith.ie/)
[![Institution](https://img.shields.io/badge/Institution-Griffith%20College%20Dublin-red)](https://www.griffith.ie/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.11%2B-blue)](https://www.python.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.9.2%2B-02569B?logo=flutter)](https://flutter.dev/)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-2.16.1-FF6F00?logo=tensorflow)](https://www.tensorflow.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.135%2B-009688?logo=fastapi)](https://fastapi.tiangolo.com/)

Hi there! Welcome to **CXC** (Chest X-ray Classifier), my Final Year Project for my **B.Sc. in Computing Science** at **Griffith College Dublin** (graduating June 2026), supervised by **Jennifer Lebron**.

CXC is an AI-powered diagnostic assistant designed to help classify chest X-rays into **Normal**, **Pneumonia**, and **Tuberculosis**, while being smart enough to flag non-X-ray images as **Unknown**. It pairs deep learning models trained on over 21,000 images with a responsive, cross-platform Flutter app and a FastAPI backend.

> 📖 Looking for the full research paper, mathematical breakdowns, and training curves? Check out the complete [Thesis Documentation](docs/Joshan_John_3092883_SDP_doc.pdf).

---

## 💡 Why I Built This

Pneumonia and Tuberculosis remain two of the biggest infectious killers globally, taking millions of lives each year. Yet hospitals around the world—especially in rural or lower-resource areas—face an acute shortage of radiologists. According to European healthcare studies, the demand for medical imaging is expected to grow by 70% by 2030, while the radiologist workforce is growing by only ~1% a year.

Waiting days for an X-ray to be reviewed can delay critical treatment. I wanted to build an end-to-end tool that gives healthcare workers rapid second-opinion predictions right in their workflow, whether they're on a clinic desktop, a tablet, or an old phone.

---

## ✨ Key Features & Real-World Considerations

- **Handles Real-World Scans**: People don't always upload clean, pristine medical files. The custom model (CXC 103) was tested against real smartphone photos taken of physical X-ray films and handled ambient lighting and glare reliably.
- **The "Unknown" Class Safeguard**: Most medical classification models assume every uploaded file is an X-ray. If someone uploads a photo of a dog or a fractured arm, those models will force a diagnosis. CXC was trained with a dedicated "Unknown" class (1,155 random non-chest images in training, 135 in test) so it politely rejects invalid inputs instead of guessing.
- **Prioritizing Patient Safety (Recall over raw accuracy)**: In medicine, a false negative is far worse than a false positive. Misclassifying a Tuberculosis patient as "Normal" can be catastrophic. The models were tuned to push recall as high as possible.
- **Batch Processing with ZIP Export**: In clinical environments, clinicians often review entire folders of scans at once. CXC lets you upload dozens of scans at a time, classifies them in parallel chunks, and lets you download a tidy ZIP sorted by diagnosis.
- **Cross-Platform & State-Preserving**: The Flutter frontend runs on Web, macOS, Windows, iOS, and Android. It uses a navigation shell with `IndexedStack` so switching tabs never resets your progress or reloads your scans.

---

## 🧪 Model Journey & Comparison

I experimented with two parallel paths: building lightweight custom CNNs from scratch (the **CXC 100-series**) and fine-tuning proven transfer learning architectures (the **CXC 200-series**).

| Model | Architecture | Input Size | Key Highlights | Test Acc | Val Acc | Clinical Safety |
|:---|:---|:---:|:---|:---:|:---:|:---:|
| **CXC 101** | Custom CNN (3 conv blocks) | $224 \times 224$ | First prototype. Suffered from gradient divergence in later epochs and missed 38 TB cases. | 89.19% | 88.04% | ⚠️ Low |
| **CXC 102** | Custom CNN + Keras Tuner | $384 \times 384$ | Scaled resolution and parameters (>104M total). Over-parameterized and missed 112 TB cases. | 83.56% | 85.28% | ⚠️ Low |
| **CXC 103** | **Custom CNN + Per-Block BatchNorm** | $224 \times 224$ | Added Batch Normalization after every block. Stable, fast, and remarkably robust on phone camera photos of films. | **96.07%** | **96.06%** | ✅ Medium |
| **CXC 201** | InceptionV3 Transfer | $224 \times 224$ | Pretrained ImageNet weights with a custom dense head. Solid pneumonia detection (97% recall), but lagged on TB (79%). | 89.46% | 91.20% | ⚠️ Low |
| **CXC 202** | VGG-16 Transfer | $224 \times 224$ | Deeper representation. 98% recall on Pneumonia, 87% on TB. | 92.53% | 94.88% | ✅ Medium |
| **CXC 203** | **ResNet50 Transfer (Champion)** | $224 \times 224$ | Residual connections prevented vanishing gradients. **0 false negatives for Pneumonia** (100% recall) and only 16 TB cases missed. | **97.25%** | **98.03%** | 🏆 High |

---

## 📁 Dataset Breakdown

The dataset was curated from publicly available Kaggle radiological collections (notably Rifatul Islam Majumder) and expanded with the out-of-distribution Unknown set:

| Class | Training (19,327) | Validation (761) | Test (1,527) |
|:---|:---:|:---:|:---:|
| 🫁 **Normal** | 6,083 | 274 | 548 |
| 🦠 **Pneumonia** | 6,165 | 213 | 427 |
| 🧫 **Tuberculosis** | 5,924 | 207 | 417 |
| ❓ **Unknown** | 1,155 | 67 | 135 |

---

## 🏛️ Project Architecture

The repo is organized as a clean monorepo:

```text
CXC-FYP-Griffith/
├── docs/                          # Detailed thesis paper & diagrams
├── frontend/                      # Flutter client app
│   ├── lib/
│   │   ├── features/              # Modular feature-first architecture
│   │   │   ├── auth/              # Firebase authentication
│   │   │   ├── home/              # Single-scan diagnosis & confidence visualization
│   │   │   ├── batch/             # Multi-image processing & ZIP download
│   │   │   └── docs/              # In-app model specifications & guidance
│   │   ├── core/                  # Navigation shell, responsive helpers, theme
│   │   └── main.dart
│   └── pubspec.yaml
└── backend/                       # FastAPI backend & model training
    ├── src/
    │   ├── api/                   # REST routes & services
    │   │   ├── routers/           # Prediction and model endpoints
    │   │   ├── services/          # Inference logic & in-memory model cache
    │   │   └── middleware/        # Firebase JWT bearer token verification
    │   ├── registry/              # Model registry, preprocessing & metadata
    │   └── utils/                 # Metrics, confusion matrix & ROC generation
    ├── notebook/                  # Jupyter notebooks for model experiments
    └── pyproject.toml
```

---

## ⚡ Quick Start

### 1. Backend (FastAPI)
```bash
cd backend

# Install dependencies (using uv or pip)
uv sync   # or: pip install -e .

# Setup environment variables
cp .example.env .env

# Start the dev server
uvicorn src.api.main:app --reload --port 8000
```
API docs are available interactively at `http://localhost:8000/docs`.

### 2. Frontend (Flutter)
```bash
cd frontend

# Fetch packages
flutter pub get

# Launch on Chrome, macOS, or your connected device
flutter run -d chrome
```

---

## 💬 Acknowledgements & Supervision

A massive thank you to **Jennifer Lebron** (Computing Program Director and Supervisor at Griffith College Dublin) for her invaluable guidance and feedback throughout this project. Sincere thanks also to **Dr. Ryan Roby** for facilitating conversations with practicing radiologists and clinical technicians, and **Dr. Abubakr Siddig** for machine learning mentorship.

---

## 📄 License
This project is open-source under the [MIT License](LICENSE).
