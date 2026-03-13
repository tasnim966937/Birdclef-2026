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
