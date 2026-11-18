from pathlib import Path
import json

import numpy as np
from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parent
FIGMA = ROOT / "Figma"
SIMULATOR = ROOT / "Simulator" / "Final"
OUTPUT = ROOT / "Diff"
OUTPUT.mkdir(parents=True, exist_ok=True)

SCREENS = {
    "shelf": (402, 874),
    "home": (402, 874),
    "detail": (402, 874),
    "setup": (402, 874),
    "invite": (392, 874),
    "first": (402, 874),
    "ready": (402, 874),
    "horizontal": (392, 874),
}


def reference(name: str, size: tuple[int, int]) -> Image.Image:
    image = Image.open(FIGMA / f"{name}.png").convert("RGB")
    if name in {"invite", "horizontal"}:
        # Figma's screenshot endpoint includes the frame's 37 px canvas shadow.
        image = image.crop((37, 37, 37 + size[0], 37 + size[1]))
    return image.crop((0, 0, size[0], size[1]))


def simulator(name: str, size: tuple[int, int]) -> Image.Image:
    image = Image.open(SIMULATOR / f"{name}.png").convert("RGB")
    return image.resize(size, Image.Resampling.LANCZOS)


results = {}
for name, size in SCREENS.items():
    ref = reference(name, size)
    sim = simulator(name, size)
    ref.save(OUTPUT / f"{name}-figma-aligned.png")
    sim.save(OUTPUT / f"{name}-simulator-aligned.png")
    Image.blend(ref, sim, 0.5).save(OUTPUT / f"{name}-overlay.png")

    ref_array = np.asarray(ref, dtype=np.int16)
    sim_array = np.asarray(sim, dtype=np.int16)
    delta = np.abs(ref_array - sim_array)
    mask = np.ones((size[1], size[0]), dtype=bool)
    # iPhone 17 Pro has a physical Dynamic Island while the source artboards use
    # a status-bar-only device template. Hardware chrome is not application UI.
    mask[:59, :] = False
    mask[860:, :] = False
    values = delta[mask]
    per_pixel = delta.max(axis=2)

    heat = np.zeros_like(ref_array, dtype=np.uint8)
    heat[..., 0] = np.clip(per_pixel * 3, 0, 255).astype(np.uint8)
    heat[..., 1] = (ref_array[..., 1] * 0.18).astype(np.uint8)
    heat[..., 2] = (ref_array[..., 2] * 0.18).astype(np.uint8)
    heat[~mask] = np.array([35, 35, 35], dtype=np.uint8)
    Image.fromarray(heat).save(OUTPUT / f"{name}-diff.png")

    results[name] = {
        "figma_node_visible_size": [size[0], size[1]],
        "mean_absolute_error_0_255": round(float(values.mean()), 3),
        "rmse_0_255": round(float(np.sqrt(np.mean(values.astype(np.float64) ** 2))), 3),
        "pixels_over_16_percent": round(float((per_pixel[mask] > 16).mean() * 100), 3),
        "masked_hardware_rows": "0-58 and 860-873",
        "overlay": f"Diff/{name}-overlay.png",
        "diff": f"Diff/{name}-diff.png",
    }

(ROOT / "results.json").write_text(json.dumps(results, indent=2) + "\n")
print(json.dumps(results, indent=2))
