# Asset Plan

This project can use AI-generated raster art for early concept assets and placeholder production art.

## First Batch

- `assets/characters/buliangren-concept.png`: Tang dynasty constable concept, dark red and black uniform, waist blade, readable silhouette.
- `assets/characters/bandit-concept.png`: West Market alley bandit, rough linen, short blade, grounded Tang-era fantasy style.
- `assets/maps/west-market-night-concept.png`: Chang'an West Market at night, lanterns, spice stall, wet stone road, Tang architectural silhouettes.
- `assets/ui/battle-panel-concept.png`: restrained dark lacquer and bronze UI panel style, suitable for a turn-based RPG battle interface.
- `assets/reference/hd2d-style-board.png`: a single style board showing the target blend of pixel characters, 2.5D environment depth, lantern light, and Tang-market props.

## Image Generation Notes

Use gpt-image-2 / the built-in image generation path for concept art. For transparent game sprites, generate on a flat chroma-key background first, then remove the background locally.

Keep generated assets as references until the combat loop and map prototype are fun. Avoid spending too much time polishing art before the gameplay skeleton works.
