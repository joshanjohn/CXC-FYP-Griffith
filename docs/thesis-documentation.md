# CXC: Chest X-ray Classifier

**Academic Dissertation / Final Year Project Documentation**  
**Author**: Joshan John (Student ID: 3092883)  
**Degree**: B.Sc. in Computing Science  
**Institution**: Griffith College Dublin  
**Submission Date**: June 2026  
**Supervisor**: Jennifer Lebron  

---

## Abstract

The Chest X-ray Classifier (CXC) project is an end-to-end deep learning system developed to automatically classify chest X-ray images into four categories: **Normal**, **Pneumonia**, **Tuberculosis (TB)**, and **Unknown**. Built using Python, TensorFlow, and Keras, the project explores and compares both custom-designed Convolutional Neural Network (CNN) models and well-established transfer learning architectures such as ResNet50, VGG16, and InceptionV3. The objective was to evaluate how different network architectures, image resolutions, and training strategies affect classification performance. To improve the reliability of predictions, an additional Unknown class was introduced into the final dataset of 19,327 images, enabling the system to identify images that do not belong to the target disease categories and reducing incorrect classifications.

Among the custom CNN models developed in the CXC 100-series, **CXC 103** achieved the best performance by incorporating Batch Normalization layers after convolutional operations. This model reached a test accuracy of 96.07% and a validation accuracy of 96.06%, demonstrating stable training and strong generalization. For the transfer learning models in the CXC 200-series, **CXC 203**, based on the ResNet50 architecture, delivered the highest overall performance with a test accuracy of 97.25% and a validation accuracy of 98.03%.

To make the system accessible and practical for real-world use, the trained models were integrated into a FastAPI backend secured using Firebase Authentication JSON Web Token (JWT) authentication. A responsive frontend cross-platform application was developed using the Flutter framework and the Dart programming language, allowing the application to run consistently across multiple platforms. The system supports single-image prediction, confidence score visualization, multi-model testing, and batch processing of chest X-ray images. Batch prediction results are automatically organized and exported as downloadable ZIP files, providing users with an efficient and user-friendly diagnostic support tool.

---

## 1. Introduction

### 1.1 Medical Imaging and Challenges
Medical images include X-rays, CT scans, MRIs, ultrasound images, and other specialized imaging modalities used in clinical practice. Unlike conventional images captured using standard digital cameras, medical images are produced using dedicated medical instruments designed to capture internal structures of the human body. As a result, their quality, resolution, and characteristics differ significantly from natural images.

For instance, many medical images, such as X-rays, are single-channel (grayscale), meaning they represent variations in intensity using only black and white rather than multiple colour channels. These differences make medical image analysis more complex and require specialized machine learning techniques that can effectively handle variations in contrast, noise, and structure.

### 1.2 Tuberculosis and Pneumonia in Chest X-rays
Tuberculosis (TB) is a serious bacterial or viral infection caused by *Mycobacterium tuberculosis*, which is contagious and air-transmissible, primarily affecting human lungs. As many as 13 million individuals in the United States have latent TB. Similarly, Pneumonia is an infection where the alveoli (air sacs) become inflamed and filled with fluid. Both are potentially fatal conditions.

Diagnosing both conditions from chest radiographs relies on black-and-white opacity pattern recognition:
- **Tuberculosis**: Observed as infiltrates commonly localized in the apical or upper lung lobes. As the disease advances, cavitations, scarring, and distorted hilum can appear.
- **Pneumonia**: Characterized by lobar, diffuse, or patchy consolidations (dense, homogeneous opacities obscuring the margins of lung lobes) primarily distributed across the lower lobes.

### 1.3 Global Impact
- **Pneumonia**: Leading infectious cause of death worldwide, responsible for approximately 2.5 million deaths annually (WHO).
- **Tuberculosis**: Deadliest single infectious killer alongside COVID-19, affecting over 10 million individuals and causing more than 1.2 million deaths annually.
- **Clinical Bottlenecks**: Significant workforce gaps in radiology. The European Union Radiation, Education, Staffing & Training (EU-REST) project highlights that while imaging demand will surge ~70% by 2030, radiologist headcount grows at only ~1% per year, exacerbated by an aging workforce (45% over age 51).

### 1.4 Project Objectives
1. Design and develop an automated chest X-ray classification pipeline discerning between Normal, Pneumonia, Tuberculosis, and non-X-ray Unknown artifacts.
2. Formulate and compare custom lightweight CNN architectures against industry transfer learning baselines (ResNet50, VGG16, InceptionV3).
3. Evaluate the models under clinical safety benchmarks, prioritizing high Recall / Sensitivity to minimize dangerous false negatives (misclassifying disease as healthy).
4. Deliver a production-grade, modular backend with FastAPI, secure Firebase JWT middleware, in-memory model caching, and batch inference streaming.
5. Engineer a responsive cross-platform client with Flutter/Dart utilizing Feature-First modularity, responsive design breakpoints, state preservation via navigation shells, and ZIP file export capabilities.

---

## 2. Methodology & Theoretical Foundations

### 2.1 Convolutional Neural Networks
Unlike classical multi-layer perceptrons or hand-engineered spatial extractors (SIFT, HOG), CNNs preserve 2D spatial relationships through convolutional kernel parameter sharing. Local receptive fields sweep over feature maps, detecting hierarchical representations from low-level edges to complex pathological consolidations and cavitations.

### 2.2 Activation Functions & Non-Linearity
Non-linear activation functions prevent the network from collapsing mathematically into a linear regression model. While Sigmoid was initially evaluated in CXC 101, Rectified Linear Unit ($\text{ReLU}(x) = \max(0, x)$) proved superior in deeper layers, mitigating vanishing gradient bottlenecks. Softmax normalization produces mutually exclusive multi-class probability distributions in the final classification head:

$$\sigma(z)_i = \frac{e^{z_i}}{\sum_{j=1}^{K} e^{z_j}}$$

### 2.3 Batch Normalization
Deep neural networks suffer from internal covariate shift, where layer activation distributions drift throughout training. Batch Normalization normalizes mini-batch outputs before activation:

$$\hat{x}^{(k)} = \frac{x^{(k)} - \mathrm{E}[x^{(k)}]}{\sqrt{\mathrm{Var}[x^{(k)}] + \epsilon}}$$

$$y^{(k)} = \gamma^{(k)} \hat{x}^{(k)} + \beta^{(k)}$$

Where $\gamma$ and $\beta$ are learnable scale and shift parameters. Incorporating Batch Normalization in CXC 103 stabilized gradient flow, accelerated convergence, and yielded a test accuracy of 96.07%.

### 2.4 Clinical Safety Metrics: Recall Priority
In clinical decision support, false negatives (classifying a sick patient as "Normal") carry severe consequences. Therefore, Recall (Sensitivity) serves as the primary medical reliability metric:

$$\text{Recall} = \frac{\text{TP}}{\text{TP} + \text{FN}}$$

---

## 3. System Architecture & Engineering

### 3.1 Technology Stack
- **Machine Learning**: Python 3.11+, TensorFlow 2.16.1, Keras 3, Keras Tuner, Scikit-learn, Polars, NumPy, Pillow.
- **Backend API**: FastAPI, Uvicorn, Firebase Admin SDK (JWT Bearer Token verification), Pydantic v2, Python-multipart.
- **Frontend Application**: Flutter SDK (^3.9.2), Dart, Firebase Auth, HTTP client, Responsive layout builder.
- **Version Control**: Git & GitHub monorepo structure.

### 3.2 Backend Design Pattern
The backend is structured under a layered, separation-of-concerns pattern:
- **Routes Layer (`src/api/routers/`)**: Declares REST endpoints (`PredictionRoute.py`, `ModelRoute.py`) with zero business logic.
- **Services Layer (`src/api/services/`)**: Orchestrates inference workflows, image loading, memory caching, and batch session lifecycle (`PredictionService.py`, `ModelService.py`).
- **Middleware Layer (`src/api/middleware/`)**: Global router-level dependency injection (`api_deps.py`) validating Google Firebase public key certificates against `FIREBASE_PROJECT_ID`.
- **Model Registry (`src/registry/model/`)**: Central catalog of model metadata, preprocessing routines, input resolutions, and label mappings.
- **Utilities (`src/utils/`)**: Reusable image decoding, confusion matrix generation, and ROC curve analysis.

### 3.3 Available Backend Endpoints

| HTTP Method | Endpoint | Description |
|:---|:---|:---|
| `GET` | `/health` | Liveness and health check probe |
| `GET` | `/models` | Returns list of available model aliases |
| `GET` | `/get_model_info` | Detailed model specifications, parameters, and training metrics |
| `POST` | `/predict` | Single image inference returning top class and confidence distribution |
| `POST` | `/batch/start` | Initializes a temporary batch session identifier |
| `POST` | `/predict/batch` | Bulk inference stream for uploaded scans within an active session |
| `GET` | `/batch/download` | Bundles segregated predictions into a downloadable ZIP archive |

### 3.4 Frontend Design Pattern
- **Feature-First Organization (`lib/features/`)**: High cohesion per domain feature, broken down into:
  - `models/`: Immutable Dart data classes with JSON serialization.
  - `views/`: Flutter UI composed of full screens (`pages/`) and reusable modular `widgets/`.
  - `controllers/`: State managers handling user input and triggering services.
  - `services/`: API interaction and hardware access (camera, file picker, secure storage).
- **Adaptive Layout**: `LayoutBuilder` dynamically adjusts between mobile single-column views and tablet/desktop multi-column card views.
- **Navigation Shell**: `MainShell` maintains background state using an `IndexedStack` to prevent UI destruction across tab changes.

---

## 4. Dataset & Data Preprocessing

### 4.1 Dataset Composition & The "Unknown" Class
The training, validation, and test datasets were assembled from publicly accessible radiological archives (including Kaggle / Rifatul Islam Majumder). A critical design innovation was the introduction of an **Unknown** class consisting of non-chest X-rays and everyday objects. This safeguards the clinical utility of the model by preventing forced false positives when invalid images are supplied.

#### Dataset Distribution Table

| Split | Normal | Pneumonia | Tuberculosis | Unknown | Total |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Training Set** | 6,083 | 6,165 | 5,924 | 1,155 | **19,327** |
| **Validation Set** | 274 | 213 | 207 | 67 | **761** |
| **Test Set** | 548 | 427 | 417 | 135 | **1,527** |

### 4.2 Ingestion Pipeline
- Utilized TensorFlow `image_dataset_from_directory` with `color_mode='rgb'`, `batch_size=32`, and `label_mode='categorical'`.
- Dynamic on-the-fly data augmentation: random horizontal flips, rotation, zoom, translation, and contrast adjustments.

---

## 5. Model Development & Iteration

### 5.1 Custom CNN Models (CXC 100-Series)

#### CXC 101 (Baseline Prototype)
- **Input Resolution**: $224 \times 224 \times 3$
- **Architecture**: Initial Batch Normalization layer, 3 convolutional blocks (32, 64, 128 filters) with MaxPooling2D, Flatten (86,528 dimensions), Dense (128 units, Dropout 0.5), Softmax output (4 units).
- **Parameters**: 33,508,454 total (11,169,482 trainable).
- **Observation**: Achieved 88.04% validation accuracy, but exhibited divergence in later training epochs with a sharp simultaneous increase in training and validation loss. High TB false-negative rate (38 cases missed).

#### CXC 102 (Hyperparameter Tuned & High Resolution)
- **Input Resolution**: $384 \times 384 \times 3$
- **Architecture**: Tuned with Keras Tuner, expanded feature maps, Dense layer with 34,668,672 parameters, learning rate 0.0001.
- **Parameters**: >104 million total (~34.7 million trainable).
- **Observation**: Over-parameterization caused training instability and poor generalizability. Reached only 83.56% test accuracy and 85.28% validation accuracy. 112 TB cases were incorrectly classified as Normal.

#### CXC 103 (Optimized Custom Architecture)
- **Input Resolution**: $224 \times 224 \times 3$
- **Architecture**: Restored optimal $224 \times 224$ input size. Applied Batch Normalization after *every* convolutional layer (32, 64, 192 filters) and Dense classification layer.
- **Parameters**: 50,235,918 total (16,745,028 trainable).
- **Observation**: Highly stable convergence across 10 epochs. Reached **96.07% test accuracy** and **96.06% validation accuracy**, establishing excellent robustness on real-world smartphone photos of X-ray films.

### 5.2 Transfer Learning Models (CXC 200-Series)

#### CXC 201 (InceptionV3)
- **Backbone**: Pre-trained InceptionV3 with frozen ImageNet feature extractor (21.8M non-trainable parameters).
- **Head**: GlobalAveragePooling2D, Dense 256, Batch Normalization, Dropout, 4-unit Softmax.
- **Performance**: 89.46% test accuracy, 91.20% validation accuracy. High precision for Pneumonia (88%) but lower sensitivity for TB (79% recall).

#### CXC 202 (VGG-16)
- **Backbone**: VGG-16 feature extraction base (15.1 million parameters).
- **Head**: GlobalAveragePooling2D, Dense 256, Batch Normalization, Dropout.
- **Performance**: 92.53% test accuracy, 94.88% validation accuracy. Improved Pneumonia recall (98%) and TB recall (87%).

#### CXC 203 (ResNet50 - Champion Model)
- **Backbone**: ResNet50 residual shortcut network (23.58M non-trainable parameters).
- **Head**: GlobalAveragePooling2D, Dense 256, Batch Normalization (1,024 params), Dropout, 4-unit Softmax.
- **Total Parameters**: 25,166,478 (526,084 trainable, 23,588,224 frozen).
- **Performance**: **97.25% test accuracy**, **98.03% validation accuracy**.
- **Clinical Safety**: **Zero false negatives for Pneumonia** (100% recall). Only 16 TB cases out of 417 misclassified as normal.

---

## 6. Comprehensive Model Comparison

| Model Alias | Architecture Type | Input Size | Trainable Params | Test Accuracy | Validation Accuracy | Medical Error Threshold |
|:---|:---|:---:|:---:|:---:|:---:|:---:|
| **CXC 101** | Custom CNN (3-block) | $224 \times 224$ | 11,169,482 | 89.19% | 88.04% | Low |
| **CXC 102** | Custom CNN + Keras Tuner | $384 \times 384$ | ~34,700,000 | 83.56% | 85.28% | Low |
| **CXC 103** | Custom CNN + Block BatchNorm | $224 \times 224$ | 16,745,028 | 96.07% | 96.06% | Medium |
| **CXC 201** | InceptionV3 Transfer | $224 \times 224$ | 526,084 | 89.46% | 91.20% | Low |
| **CXC 202** | VGG16 Transfer | $224 \times 224$ | ~526,000 | 92.53% | 94.88% | Medium |
| **CXC 203** | **ResNet50 Transfer** | $224 \times 224$ | **526,084** | **97.25%** | **98.03%** | **High** |

---

## 7. Conclusions & Future Directions

### 7.1 Key Achievements
- Demonstrated that combining deep learning with lightweight cross-platform software bridges the gap between academic research and clinical utility.
- CXC 203 achieved clinical-grade screening benchmark performance (97.25% test accuracy and zero Pneumonia false negatives).
- Custom CNN CXC 103 showed that proper normalization and regularization allow lightweight architectures to perform reliably on ambient photography of physical radiographs.

### 7.2 Future Enhancements
- **Ensemble Inference**: Weighted voting between CXC 103 and CXC 203 to further suppress edge-case false positives.
- **Pathology Localization & Segmentation**: Integration of YOLO / U-Net architectures for bounding-box and segmentation masks of lung infiltrates and cavitations.
- **Pathology Expansion**: Extending classification to Pleural Effusion, Chronic Obstructive Pulmonary Disease (COPD), and Lung Malignancies.
- **Production CI/CD**: Automated integration testing and continual retraining pipelines for new institutional X-ray datasets.

---

## 8. Academic References

1. EIT Health, "Machine learning in healthcare: Uses, benefits and pioneers in the field," May 2026.
2. AuntMinnie, "AI cuts time for radiologists reporting fractures on x-rays," May 2026.
3. Cleveland Clinic, "What Is Tuberculosis?," May 2026.
4. Health Service Executive (HSE.ie), "Pneumonia," May 2026.
5. Medical News Today, "Chest X-ray for tuberculosis (TB): What to expect," May 2026.
6. Radiology Masterclass, "Chest X-ray - Pulmonary disease: Tuberculosis," May 2026.
7. Centers Urgent Care, "Spotting Pneumonia on X-Ray and What It Means," May 2026.
8. Knya, "Difference between Pneumonia and Tuberculosis X-ray," May 2026.
9. Radiology Masterclass, "Chest X-ray - Atypical Pneumonia," May 2026.
10. Every Breath Counts, "The Issues: Pneumonia," May 2026.
11. World Health Organization (WHO), "Tuberculosis Fact Sheet," May 2026.
12. A. P. Brady et al., "A project to define standards for radiology staffing, education and training across the European Union (EU-REST)," *Insights Imaging*, vol. 16, no. 1, p. 56, Mar. 2025.
13. A. P. Brady et al., "Guidelines and recommendations for radiologist staffing," *Insights Imaging*, 2025.
14. S. Iqbal et al., "Analyses of Medical Images Using Traditional ML and CNNs," *Arch Computat Methods Eng*, 2023.
15. P. Rajpurkar et al., "CheXNet: Radiologist-Level Pneumonia Detection on Chest X-Rays with Deep Learning," *arXiv:1711.05225*, 2017.
16. Frontiers, "Edge AI for Healthcare Operations," May 2026.
17. A. Rocha et al., "Edge AI for Internet of Medical Things," *Computers and Electrical Engineering*, 2024.
18. V. Bundele et al., "Evaluating Self-Supervised Learning in Medical Imaging," *arXiv:2412.19124*, 2026.
19. H. Guo et al., "Curriculum self-supervised learning in endoscopy," *Sci Rep*, 2024.
20. H. Laçi et al., "Deep learning approaches for classification in medical imaging," *BMC Med Imaging*, 2025.
21. J. W. Kim et al., "Systematic Review of Hybrid Vision Transformer Architectures," *J Digit Imaging*, 2025.
22. M. Ghassemi et al., "Review of Challenges and Opportunities in ML for Health," *AMIA*, 2020.
23. A. Kanapari et al., "Applications and challenges of ML in clinical trials," *Digit Health*, 2025.
24. S. Srivastava et al., "Multi-class deep learning architecture for COVID-19, tuberculosis, and pneumonia," *J Med Imaging Radiat Sci*, vol. 56, no. 6, 2025.
25. Keras Documentation, "Keras Applications: Transfer Learning Models," 2026.
26. G. Kourounis et al., "Computer image analysis with artificial intelligence: practical introduction for medical professionals," *Postgrad. Med. J.*, 2023.
27. Stanford ML Group, "CheXNet Projects," 2026.
28. The Data Frog, "The 1-Neuron Network: Logistic Regression," 2026.
29. The Deep Hub, "Convolutional Neural Networks: Comprehensive Guide," 2026.
30. GeeksforGeeks, "Activation functions in Neural Networks," 2026.
31. Radiopaedia, "Lobar pneumonia," 2026.
32. StatPearls, "Pneumonia Pathology," 2026.
33. Radiopaedia, "Tuberculosis (pulmonary manifestations)," 2026.
34. Radiology Masterclass, "Pulmonary disease: Tuberculosis X-ray," 2026.
35. Keras Documentation, "ResNet50 Applications Reference," 2026.
