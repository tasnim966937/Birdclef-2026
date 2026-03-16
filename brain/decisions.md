# Decisions Log

## 2026-03-11: Three-phase approach (EDA -> BirdNET -> Custom Model)
**Choice**: Start with EDA, then BirdNET baseline, then custom EfficientNet
**Over**: Jumping straight into custom deep learning model
**Because**: User is new to audio ML. Seeing spectrograms first builds intuition. BirdNET gives a free baseline to beat. Phased approach reduces overwhelm.

## 2026-03-11: Deep learning over traditional ML
**Choice**: EfficientNet-B0 CNN on mel spectrograms
**Over**: Random forests, SVM, XGBoost on handcrafted features
**Because**: Every BirdCLEF winner (2021-2025) uses deep learning. Traditional ML can't compete. EfficientNet-B0 is small enough for 90-min CPU inference.

## 2026-03-11: EfficientNet-B0 as primary architecture
**Choice**: EfficientNet-B0 (5.3M params) from timm library
**Over**: Larger models (ResNet-50, EfficientNetV2-S, transformers)
**Because**: Best speed/accuracy tradeoff for CPU-only inference. Proven in BirdCLEF 2025 (top-2% used B0). Can ensemble with B1/B3 later if time permits.

## 2026-03-11: Mel spectrogram as input representation
**Choice**: Convert OGG audio to mel spectrograms (2D images)
**Over**: Raw waveform, MFCC, Wav2Vec embeddings
**Because**: Mel spectrograms + CNN is the dominant winning approach. Raw audio (Wav2Vec) failed in 2025 (0.6 AUC vs 0.9 AUC). User's remote sensing background makes image-based approach intuitive.

## 2026-03-11: C1 architecture -- SED + 20-sec + CrossEntropy
**Choice**: SED head with GeM pooling, 20-sec chunks, CrossEntropy loss
**Over**: Simple classifier head, 5-sec chunks, BCE loss (C0)
**Because**: 2025 1st place proved 20-sec chunks give +0.03 AUC. SED head enables per-frame predictions. CrossEntropy slightly outperformed BCE. Result: 0.9773 vs C0's 0.968.

## 2026-03-11: Batch size 180 for training
**Choice**: BS 180 (~35-38 GB on A40)
**Over**: BS 160 (safer) or BS 200+ (tighter)
**Because**: User tested on A40 and confirmed 180 leaves ~10 GB headroom. Good balance of speed and safety.

## 2026-03-11: Pseudo-labeling strategy (C2)
**Choice**: Sliding window (20-sec, 5-sec step), 5-fold ensemble, average overlapping predictions
**Over**: Non-overlapping windows, single model
**Because**: Overlapping windows reduce noise. 5-fold ensemble is more robust. 2025 1st place used this exact approach. Generated 127,104 pseudo-label rows in 53 minutes.

## 2026-03-11: MixUp ratio 1.0 for C2
**Choice**: Every clean sample mixed 50/50 with a pseudo-labeled soundscape sample
**Over**: Random MixUp within clean data only (C1 approach)
**Because**: 2025 1st place reported +0.026 AUC from MixUp ratio 1.0 vs 0. Forces model to learn species in noisy multi-species context.

## 2026-03-11: Stochastic Depth 0.15 for C2
**Choice**: drop_path_rate=0.15 during C2 training
**Over**: No drop path (C1)
**Because**: 2025 1st place reported +0.005 per model. Acts as regularization during semi-supervised training. Minimal compute overhead.

## 2026-03-11: Models excluded from git
**Choice**: Gitignore all model weights, push only code
**Over**: Including model weights in repo
**Because**: Intermediate weights (C0, C1, C2) are not final inference models. Final ONNX/OpenVINO models will be added later. Keeps repo lightweight.
