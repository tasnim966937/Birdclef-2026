---
name: BirdCLEF 2026 Full Roadmap
overview: "Complete roadmap to target 1st place in BirdCLEF+ 2026, incorporating proven techniques from all top 2024-2025 solutions: multi-iterative noisy student, SED models, 20-sec chunks, extra Xeno-Canto data, and ensemble strategies."
todos:
  - id: c0-baseline
    content: "Phase C0: Simple EfficientNet-B0 baseline (5-sec, BCE, no SED) -- 0.968 CV AUC"
    status: completed
  - id: c1-dataset
    content: "Phase C1: Build PyTorch Dataset (OGG -> 20-sec chunk -> mel spectrogram -> tensor)"
    status: in_progress
  - id: c1-model
    content: "Phase C1: Build EfficientNet-B0 + SED head model"
    status: in_progress
  - id: c1-train
    content: "Phase C1: Training loop with MixUp, CrossEntropy, 5-fold CV, 15 epochs"
    status: in_progress
  - id: c1-validate
    content: "Phase C1: Validate on held-out fold, compute macro ROC-AUC"
    status: pending
  - id: c2-pseudo
    content: "Phase C2: Pseudo-label 10,592 unlabeled soundscapes with C1 model"
    status: pending
  - id: c2-retrain
    content: "Phase C2: Retrain with MixUp ratio 1.0, Stochastic Depth, WeightedRandomSampler"
    status: pending
  - id: c3-iterate
    content: "Phase C3: Multi-iterative pseudo-labeling (2-4 rounds) with power transform"
    status: pending
  - id: c3-upgrade
    content: "Phase C3: Upgrade to EfficientNet-B3/B4, ECA-NFNet-L0, RegNetY"
    status: pending
  - id: c4-xc-data
    content: "Phase C4: Download extra Xeno-Canto data for target + Amphibia/Insecta species"
    status: pending
  - id: c4-pretrain
    content: "Phase C4: Pre-train on previous BirdCLEF 2021-2025 data"
    status: pending
  - id: c4-amphibia
    content: "Phase C4: Train separate Amphibia/Insecta model"
    status: pending
  - id: c5-ensemble
    content: "Phase C5: Build 7-model ensemble from different iterations and backbones"
    status: pending
  - id: c5-optimize
    content: "Phase C5: ONNX -> OpenVINO fp16 export, benchmark CPU inference under 90 min"
    status: pending
  - id: c5-kaggle
    content: "Phase C5: Build Kaggle inference notebook with sliding window + smoothing + TTA"
    status: pending
isProject: false
---

# BirdCLEF+ 2026 -- Competition Roadmap (Target: 1st Place)

## Current Status

- Phase A (EDA): DONE
- Phase B (BirdNET): DONE (understood audio classification flow)
- Phase C0 (Simple EfficientNet-B0, 5-sec, BCE, no SED): DONE -- 0.968 CV AUC
- Phase C1 (EfficientNet-B0 + SED, 20-sec, CrossEntropy): IN PROGRESS -- Fold 0 training running

## Competition Constraints

- **Inference:** CPU only, 90 minutes max
- **Metric:** Macro ROC-AUC (every species counts equally)
- **Hardware:** A40 GPU (48GB VRAM) on Linux VM for training
- **Data path:** `/data/scratch/scienceteam/jupyter-mir/bird/Data/birdclef-2026/`
- **Conda env:** `bird` (Python 3.11)

---

## Phase C0: Quick Baseline -- DONE (0.968 CV AUC)

**Goal:** Prove the pipeline works end-to-end with a simple setup.

- Notebook: `Phase_C_EfficientNet_1_Train.ipynb`
- 5-second chunks, simple classification head (no SED)
- `efficientnet_b0` from `timm`, BCEWithLogitsLoss
- `n_fft=1024`, `hop_length=512`, `n_mels=128`, `fmin=20`
- Batch size 32, lr=1e-3, weight_decay=1e-2
- MixUp alpha=0.15 (beta distribution)
- 5-fold CV, 20 epochs, patience=3
- **Result: 0.968 mean CV AUC**

This model is **not** used as a starting point for C1. C1 is a completely new architecture.

---

## C0 vs C1: Key Differences

| Parameter           | C0 (Baseline)              | C1 (SED)                            |
| ------------------- | -------------------------- | ------------------------------------ |
| Notebook            | `Phase_C_EfficientNet_1_Train.ipynb` | `Phase_C1_SED_20sec.ipynb` |
| Chunk duration      | 5 sec                      | **20 sec**                           |
| n_fft               | 1024                       | **4096**                             |
| hop_length          | 512                        | **1252**                             |
| n_mels              | 128                        | **224**                              |
| fmin                | 20                         | **0**                                |
| Input shape         | (3, 128, 313)              | **(3, 224, 512)**                    |
| Model head          | Simple linear classifier   | **SED head (GeM pool + per-frame)** |
| Loss function       | BCEWithLogitsLoss          | **CrossEntropy**                     |
| MixUp strategy      | Beta(0.15, 0.15) blend     | **Fixed weight=0.5, max targets**   |
| Backbone            | `efficientnet_b0`          | **`tf_efficientnet_b0.ns_jft_in1k`** |
| Batch size          | 32                         | **180**                              |
| Learning rate       | 1e-3                       | **5e-4**                             |
| Weight decay        | 1e-2                       | **1e-4**                             |
| Epochs              | 20                         | **15**                               |
| Audio normalization | None                       | **Absmax normalization**             |
| Based on C0?        | N/A                        | **No -- trains from scratch**       |

**Why the loss values look different:** BCE loss outputs small numbers (0.01-0.5 range) because it's 234 independent binary predictions. CrossEntropy outputs larger numbers (1.0-6.0+) because it operates across all 234 classes at once. The numbers are not comparable -- only AUC matters.

---

## Phase C1: Base Model (target ~0.85 AUC)

**Goal:** Get a working end-to-end pipeline with a single EfficientNet-B0.

- Build PyTorch Dataset: OGG -> raw waveform (32kHz) -> mel spectrogram
- Mel params (from 2025 1st place): `n_mels=224, n_fft=4096, hop_size=1252, fmin=0, fmax=16000`
- **20-second chunks** (not 5s -- proven +0.03 boost for frog/insect species)
- Input shape: `(3, 224, 512)` -- mel repeated 3x as RGB channels
- Model: `tf_efficientnet_b0.ns_jft_in1k` from `timm` + SED head (from 2021 4th place)
- SED head: per-frame predictions with GeM frequency pooling, then aggregate
- Loss: CrossEntropy (worked better than BCE for 2025 1st place)
- Optimizer: AdamW, lr=5e-4 to 1e-6, weight_decay=1e-4
- Scheduler: CosineAnnealingWarmRestarts (restart every 5 epochs)
- Augmentations: MixUp (p=0.5, constant weight 0.5), SpecAugment (time/freq masking)
- 5-fold cross-validation (each fold has at least 1 sample per label)
- Epochs: 15
- Batch size: 180 (A40 can handle it at ~35 GB)
- Normalize audio by absmax before spectrogram
- Oversample rare species (< 20 samples)

**Key files to create:**

- `src/dataset.py` -- Dataset class (OGG -> mel spectrogram)
- `src/model.py` -- EfficientNet-B0 + SED head
- `src/train.py` -- Training loop
- `src/config.py` -- All hyperparameters in one place

---

## Phase C2: Pseudo-Labeling Iteration 1 (target ~0.90 AUC)

**Goal:** Use trained model to label the 10,592 unlabeled soundscapes, then retrain.

- Run inference on all `train_soundscapes/` using best C1 ensemble
- Use overlapping sliding window inference (like remote sensing image segmentation)
- Store pseudo-labels as max probabilities per 5-sec segment
- Retrain with **MixUp ratio 1.0** -- every train sample mixed with a pseudo-labeled sample
- Use **Stochastic Depth** (drop_path_rate=0.15) -- only during self-training
- Add **WeightedRandomSampler** for pseudo-labels (weight = sum of max probs per soundscape)
- Include the 66 labeled soundscapes in training
- Epochs: 25-35
- Also train a `regnety_008.pycls_in1k` for diversity

---

## Phase C3: Multi-Iterative Noisy Student (target ~0.92+ AUC)

**Goal:** Repeat pseudo-labeling 2-4 times, each time with better models.

- Re-pseudo-label soundscapes with C2 models
- Apply **power transform** to pseudo-labels (power = 1/0.65, 1/0.55, 1/0.6) to reduce noise
- Upgrade backbones: `tf_efficientnet_b3`, `tf_efficientnet_b4`, `eca_nfnet_l0`, `regnety_016`
- Each iteration should improve AUC by ~0.01-0.02
- Stop when no further improvement (typically after 4 iterations)

Expected progression (based on 2025 1st place):

- Iteration 1: ~0.90
- Iteration 2: ~0.92
- Iteration 3: ~0.93
- Iteration 4: ~0.93+

---

## Phase C4: Extra Data + Separate Models (target ~0.93+ AUC)

**Goal:** Maximize data and build specialized models.

### Extra Xeno-Canto Data

- Download extra audio for Pantanal species from Xeno-Canto API
- Cap at 500 samples per species
- Filter: duration < 60 sec

### Extra Amphibia/Insecta Data

- Download from Xeno-Canto: ~700 species of frogs + insects
- Train a **separate EfficientNet-B0** only on Amphibia + Insecta
- BS=128, 40 epochs
- At inference, insert its predictions into the main prediction matrix

### Previous BirdCLEF Data (2021-2025)

- Download datasets from previous competitions
- Pre-train backbones on this large combined dataset
- Then fine-tune on 2026 data (transfer learning)

---

## Phase C5: Ensemble + Inference Optimization (target ~0.935 AUC)

**Goal:** Combine diverse models and optimize for 90-min CPU inference.

### Ensemble Strategy (7 models, like 2025 1st place)

- Models from different pseudo-labeling iterations (stage 1, iter 1-4)
- Different backbones (EfficientNet-B0/B3/B4, RegNetY, ECA-NFNet-L0)
- Dedicated Amphibia/Insecta model
- **Equal weights** in ensemble (worked best on private LB)
- Try **checkpoint soup** (average weights from different epochs)

### Inference Optimization

- Export all models to **ONNX -> OpenVINO fp16**
- Overlapping sliding window inference (average framewise predictions from neighboring chunks)
- Post-processing: smoothing kernel `[0.1, 0.2, 0.4, 0.2, 0.1]`
- Delta shift TTA (from 2023 2nd place)
- Multiprocess loading of test soundscapes
- Generate spectrograms once, reuse across all models
- **Must fit in 90 minutes CPU**

### Kaggle Submission Notebook

- Self-contained inference notebook
- Load model weights from Kaggle Dataset
- Read `test_soundscapes/`, predict, write `submission.csv`

---

## Key Techniques Reference


| Technique                       | Source                 | Impact                             |
| ------------------------------- | ---------------------- | ---------------------------------- |
| 20-sec chunks                   | 2025 1st               | +0.03 vs 5-sec                     |
| SED head                        | 2021 4th, 2025 all top | significant boost over simple head |
| MixUp ratio 1.0                 | 2025 1st               | +0.026 vs ratio 0                  |
| Stochastic Depth 0.15           | 2025 1st               | +0.005 per model                   |
| Power transform pseudo-labels   | 2025 1st               | enables multi-iteration            |
| Weighted pseudo-label sampler   | 2025 1st               | stabilizes training                |
| CrossEntropy loss               | 2025 1st               | slight edge over BCE               |
| Overlapping sliding window      | 2025 1st               | +0.002-0.003                       |
| Separate Amphibia/Insecta model | 2025 1st               | +0.002-0.003                       |
| Checkpoint soup                 | 2024 2nd               | free boost                         |
| Data quality filtering (80%)    | 2024 1st               | cleaner training                   |
| Pre-train on past years         | 2025 2nd               | better initialization              |
| OpenVINO fp16                   | 2025 2nd               | fast CPU inference                 |
