# Project Context

## Project Name
BirdCLEF+ 2026 Kaggle Competition

## Description
Acoustic species identification competition for the Pantanal wetlands in Brazil. Build ML models that identify 234 wildlife species (birds, frogs, insects, mammals, reptiles) from audio recordings. This is a Kaggle Code Competition -- submit a notebook, not a CSV. Inference runs on Kaggle servers: CPU only, 90-minute max.

## Tech Stack
- Python (PyTorch, timm, librosa, torchaudio, audiomentations)
- Jupyter notebooks for EDA and experiments
- Training on Linux VM with NVIDIA A40 (48GB VRAM)
- Inference must run on CPU within 90 minutes on Kaggle

## Project Structure
- `Data/birdclef-2026/` -- competition dataset (15 GB extracted)
  - `train_audio/` -- 35,549 clean single-species OGG clips across 206 species folders
  - `train_soundscapes/` -- 10,658 one-minute field recordings (66 labeled, 10,592 unlabeled)
  - `test_soundscapes/` -- empty locally, populated by Kaggle at eval time
  - `train.csv` -- metadata for train_audio (35,549 rows)
  - `train_soundscapes_labels.csv` -- labels for 66 soundscapes (1,478 5-sec segments, 75 species)
  - `taxonomy.csv` -- 234 target species with names and classes
  - `sample_submission.csv` -- format: row_id + 234 species probability columns
  - `recording_location.txt` -- Pantanal coords (Lat -16.5 to -21.6, Lon -55.9 to -57.6)

## Goals
1. Build a model that identifies 234 species from 5-second audio windows
2. Handle extreme class imbalance (1 to 499 samples per species)
3. 28 species have NO individual training clips (only in soundscape labels)
4. Meet 90-minute CPU-only inference constraint
5. Submit working Kaggle notebook

## Conventions
- Keep answers short and simple (user preference)
- User is a remote sensing expert, beginner in deep learning/audio
- Use remote sensing analogies: spectrograms = raster images, frequency bins = spectral bands
- Data sources: XC = Xeno-canto (23,043 clips), iNat = iNaturalist (12,506 clips)
- Species labels: numeric IDs = non-bird species, 6-letter codes = eBird bird codes
