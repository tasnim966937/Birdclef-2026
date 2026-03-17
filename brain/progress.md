# Progress

## Current Status
C2 v1 completed (under-performed). C2 v2 notebooks created with speed + training fixes. Next: run precompute then C2 v2.

## Recently Completed
- **Phase A (EDA)**: Spectrograms, class distributions, audio playback -- DONE
- **Phase B (BirdNET)**: Pre-trained baseline, understood audio classification flow -- DONE
- **Phase C0 (Baseline)**: EfficientNet-B0, 5-sec, BCE, no SED -- **0.968 CV AUC** -- DONE
- **Phase C1 (SED)**: EfficientNet-B0 + SED head, 20-sec, CrossEntropy -- **0.9773 CV AUC** -- DONE
  - Fold 0: 0.9724 (early stopped epoch 12)
  - Fold 1: 0.9755 (still improving at epoch 15)
  - Fold 2: 0.9785
  - Fold 3: 0.9821 (best)
  - Fold 4: 0.9780
- **C2 Step 1 (Pseudo-label)**: Labeled 10,592 unlabeled soundscapes -> 127,104 rows in 53 min -- DONE
- **C2 v1 (Retrain)**: Over-regularized, ~0.84 clean-val AUC -- DONE (abandoned)
  - Fold 0: 0.8452 (early stopped epoch 22)
  - Fold 1: 0.8300 (early stopped epoch 27)
  - Folds 2-4: still running but expected similar (~0.83-0.85)
  - Root cause: MixUp 1.0 + drop_path 0.15 too aggressive for B0
- **C2 v2 notebooks created**: precompute_spectrograms.ipynb + Phase_C2v2_Retrain.ipynb -- DONE
- **GitHub**: Pushed code to https://github.com/tasnim966937/Birdclef-2026
- **Studied 2025 solutions**: 1st, 2nd, 3rd, 4th place writeups analyzed

## Next: C2 v2 Retrain (Two Steps)

### Step 1: Pre-compute spectrograms (~1-2 hours, one-time)
- Run `precompute_spectrograms.ipynb` on Linux VM
- Creates `.npy` files for all 35,549 clean clips + 128,582 soundscape segments
- Output: `Data/precomputed_specs/train_audio/` and `Data/precomputed_specs/soundscapes/`

### Step 2: Train C2 v2 (~8-10 hours total, 5 folds)
- Run `Phase_C2v2_Retrain.ipynb`
- Key fixes: drop_path=0.05, MixUp prob=0.5 (not 1.0), Beta(0.4,0.4) weights, num_workers=16
- Dual validation: clean-clip AUC + soundscape AUC (model saved by soundscape AUC)
- Output: `models/stage2v2_sed/c2v2_fold{0-4}.pth`

## After C2 v2
1. **Phase C3**: Re-pseudo-label with C2v2 models, upgrade backbones (B3/B4), 2-4 iterations
2. **Phase C4**: Extra data (Xeno-Canto, BirdCLEF 2023 for validation)
3. **Phase C5**: Ensemble, ONNX export, Kaggle inference notebook

## Key Observations
- C1 Fold 1 was still improving at epoch 15 -> more epochs help
- Pseudo-labels show realistic detections (owls at midnight recordings)
- C2 v1 train loss barely moved (479->474 in 27 epochs) = underfitting from over-regularization
- Machine has 64 CPU cores and 1 TB RAM -- was only using 4 workers (massive bottleneck)
- Pre-computed spectrograms eliminate audio decoding + FFT at train time (5x speed boost)
- BS 180 is safe for training (37.7 GB / 48 GB)
- BS 512 works for inference (8.2 GB / 48 GB with 5 models)

## Active Issues
- 28 species have zero individual training clips (only in soundscape labels)
- Need to test Soft AUC Loss (from 2025 4th place) in C3
- Need to decide on multiple mel param sets for ensemble diversity
