# Progress

## Current Status
Planning phase complete. Ready to start Phase A (EDA notebook).

## Recently Completed
- Downloaded and extracted dataset (15 GB, 35,549 audio files + 10,658 soundscapes)
- Explored all data files and mapped how they connect
- Understood competition rules: code competition, CPU-only inference, 90-min limit
- Researched BirdCLEF 2025 winning solutions (EfficientNet + SED + pseudo-labeling)
- Created comprehensive plan with 3 phases

## Next Steps
1. **Phase A**: EDA notebook -- visualize spectrograms, listen to audio, explore class distributions
2. **Phase B**: BirdNET pre-trained baseline -- zero-training inference to get a baseline score
3. **Phase C**: Custom EfficientNet-B0 model -- train on A40 GPU, pseudo-labeling, ONNX export

## Active Issues
- Need to install Python audio libraries (librosa, soundfile) locally for EDA
- 28 species have zero individual training clips (only in soundscape labels) -- need strategy
- 90-minute CPU inference limit constrains model size
