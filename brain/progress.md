# Progress

## Current Status
Phase C2 retraining is running on the Linux VM (A40 GPU).

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
- **C2 Step 2 (Retrain)**: Notebook created, training launched -- IN PROGRESS
- **GitHub**: Pushed code to https://github.com/tasnim966937/Birdclef-2026
- **Studied 2025 solutions**: 1st, 2nd, 3rd, 4th place writeups analyzed

## Current Training: C2 Retrain
- Notebook: `Phase_C2_Retrain.ipynb`
- Training data: clean clips + 127,104 pseudo-labeled + 1,478 labeled soundscape segments
- MixUp ratio 1.0 (every batch mixed with pseudo-labeled data)
- Stochastic Depth: drop_path_rate=0.15
- 30 epochs, patience 5, batch size 180
- Output: `models/stage2_sed/c2_fold{0-4}.pth`

## Next Steps
1. Wait for C2 training to complete, check CV AUC
2. **Phase C3**: Re-pseudo-label with C2 models, upgrade backbones (B3/B4), 2-4 iterations
3. **Phase C4**: Extra data (Xeno-Canto, BirdCLEF 2023 for validation)
4. **Phase C5**: Ensemble, ONNX export, Kaggle inference notebook

## Key Observations
- C1 Fold 1 was still improving at epoch 15 -> more epochs help
- Pseudo-labels show realistic detections (owls at midnight recordings)
- BS 180 is safe for training (37.7 GB / 48 GB with Stochastic Depth)
- BS 512 works for inference (8.2 GB / 48 GB with 5 models)

## Active Issues
- 28 species have zero individual training clips (only in soundscape labels)
- Need to test Soft AUC Loss (from 2025 4th place) in C3
- Need to decide on multiple mel param sets for ensemble diversity
