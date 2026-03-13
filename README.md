# BirdCLEF+ 2026 -- Acoustic Species Identification

Solution for the [BirdCLEF+ 2026](https://www.kaggle.com/competitions/birdclef-2026) Kaggle competition. The goal is to identify bird, frog, insect, and mammal species from passive acoustic monitoring (PAM) recordings in the Pantanal wetlands, Brazil.

## Competition

- **Task:** Multi-label classification of 234 species from 5-second audio segments
- **Metric:** Macro ROC-AUC
- **Inference:** CPU only, 90-minute time limit on Kaggle servers
- **Competition page:** https://www.kaggle.com/competitions/birdclef-2026
- **Leaderboard:** https://www.kaggle.com/competitions/birdclef-2026/leaderboard

## Dataset

Download the dataset from Kaggle:

**https://www.kaggle.com/competitions/birdclef-2026/data**

After downloading, extract and place the data so the folder structure looks like:

```
Data/birdclef-2026/
├── train_audio/              # 35,549 clean single-species OGG clips (206 species)
├── train_soundscapes/        # 10,658 field recordings (66 labeled, 10,592 unlabeled)
├── test_soundscapes/         # Hidden on Kaggle (populated during submission)
├── train.csv                 # Metadata for train_audio
├── train_soundscapes_labels.csv  # 1,478 labeled 5-sec segments from 66 soundscapes
├── taxonomy.csv              # 234 target species
├── sample_submission.csv     # Submission format
└── recording_location.txt    # Pantanal coordinates
```

## Setup

```bash
conda create -n bird python=3.11 -y
conda activate bird
pip install -r requirements.txt
```

For GPU training (PyTorch with CUDA):
```bash
pip install torch torchaudio --index-url https://download.pytorch.org/whl/cu121
```

## Project Structure

```
├── Phase_A_EDA.ipynb                    # Exploratory data analysis (spectrograms, distributions)
├── Phase_B_BirdNet.ipynb                # BirdNET pre-trained model baseline
├── Phase_C_EfficientNet_1_Train.ipynb   # C0: EfficientNet-B0 baseline (5-sec, BCE) -- 0.968 CV AUC
├── Phase_C1_SED_20sec.ipynb             # C1: EfficientNet-B0 + SED head (20-sec, CrossEntropy)
├── requirements.txt                     # Python dependencies
├── plans/                               # Competition roadmap and plans
├── brain/                               # Project context and decision log
└── models/                              # (gitignored) Model weights
```

## Approach

Multi-stage pipeline inspired by top solutions from BirdCLEF 2024-2025:

1. **Phase C0:** Simple EfficientNet-B0 baseline with 5-sec chunks and BCE loss (done -- 0.968 CV AUC)
2. **Phase C1:** EfficientNet-B0 + SED head with 20-sec chunks, CrossEntropy loss, MixUp (in progress)
3. **Phase C2:** Pseudo-label 10,592 unlabeled soundscapes, retrain with noisy student
4. **Phase C3:** Multi-iterative pseudo-labeling (2-4 rounds) with backbone upgrades
5. **Phase C4:** Extra Xeno-Canto data, separate Amphibia/Insecta model, pre-train on past years
6. **Phase C5:** 7-model ensemble, ONNX/OpenVINO fp16 export, CPU inference optimization

See [plans/birdclef_2026_full_roadmap.plan.md](plans/birdclef_2026_full_roadmap.plan.md) for the full roadmap.

## Hardware

- **Training:** NVIDIA A40 (48 GB VRAM) on Linux VM
- **Inference:** CPU only (Kaggle servers, 90-min limit)
