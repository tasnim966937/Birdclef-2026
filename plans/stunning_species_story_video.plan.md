---
name: Stunning Species Story Video
overview: Create a visually stunning vertical (1080x1920) Facebook Story video with animated spectrograms, modern design, glowing playhead sweep, and smooth transitions for 10 Pantanal species.
todos:
  - id: write-script
    content: Write Python script that generates per-frame images with animated playhead, waveform, modern layout
    status: completed
  - id: render-video
    content: Run the script to render all frames and combine into final vertical video
    status: completed
isProject: false
---

# Stunning Pantanal Species Story Video

## What we're building

A 60-second vertical video (1080x1920, 9:16) with 10 species, each getting ~5 seconds. Modern, cinematic feel.

## Design per species segment (5 seconds)

- **Dark gradient background** -- not flat black, a subtle dark gradient (deep navy to black)
- **Spectrogram** in the center with rounded corners, vibrant `magma` colormap
- **Animated glowing playhead** -- a bright vertical line that sweeps left-to-right across the spectrogram in sync with the audio
- **Species name** -- large, bold, clean sans-serif font at top
- **Scientific name** -- smaller italic below it
- **Class badge** -- color-coded pill (green=Amphibian, orange=Mammal, yellow=Insect, purple=Reptile)
- **Waveform strip** -- thin waveform visualization below the spectrogram
- **Counter** -- subtle "1/10" in corner
- **Footer** -- "BirdCLEF+ 2026 | Pantanal, Brazil"

## Technical approach

Instead of static PNG frames, we generate **individual video frames** using matplotlib (one frame per ~40ms = 25fps), drawing the playhead at a different position each frame. This creates smooth animation. Each species = 125 frames at 25fps.

Then ffmpeg combines frames + audio into clips, and concatenates all 10 into the final video.

## Species (same 10, no birds)

1. Weeping Frog, 2. Jaguar, 3. Wrestler Frog, 4. Rococo Toad, 5. Milk Frog, 6. Southern Spectacled Caiman, 7. White-coated Titi, 8. Waxy Monkey Tree Frog, 9. Giant Cicada, 10. Black Howling Monkey

## File

Output: `y:\jupyter-mir\bird\pantanal_story.mp4`

Script: `y:\jupyter-mir\bird\video_temp\make_story.py`
