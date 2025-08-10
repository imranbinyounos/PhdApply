#!/usr/bin/env python3
import json
from pathlib import Path

from PIL import Image, ImageDraw


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


# === User-provided drawing logic (adapted) ===
def create_rounded_rectangle(draw: ImageDraw.ImageDraw, xy, corner_radius, fill):
    upper_left_point = xy[0]
    bottom_right_point = xy[1]
    draw.rectangle(
        [
            (upper_left_point[0], upper_left_point[1] + corner_radius),
            (bottom_right_point[0], bottom_right_point[1] - corner_radius),
        ],
        fill=fill,
    )
    draw.rectangle(
        [
            (upper_left_point[0] + corner_radius, upper_left_point[1]),
            (bottom_right_point[0] - corner_radius, bottom_right_point[1]),
        ],
        fill=fill,
    )
    draw.pieslice(
        [upper_left_point, (upper_left_point[0] + corner_radius * 2, upper_left_point[1] + corner_radius * 2)],
        180,
        270,
        fill=fill,
    )
    draw.pieslice(
        [
            (bottom_right_point[0] - corner_radius * 2, upper_left_point[1]),
            (bottom_right_point[0], upper_left_point[1] + corner_radius * 2),
        ],
        270,
        360,
        fill=fill,
    )
    draw.pieslice(
        [
            (upper_left_point[0], bottom_right_point[1] - corner_radius * 2),
            (upper_left_point[0] + corner_radius * 2, bottom_right_point[1]),
        ],
        90,
        180,
        fill=fill,
    )
    draw.pieslice(
        [
            (bottom_right_point[0] - corner_radius * 2, bottom_right_point[1] - corner_radius * 2),
            bottom_right_point,
        ],
        0,
        90,
        fill=fill,
    )


def draw_graduation_cap(draw: ImageDraw.ImageDraw, center, size, color):
    cap_width = size
    cap_height = size * 0.4
    tassel_length = size * 0.5

    top_left = (center[0] - cap_width / 2, center[1] - cap_height / 2)
    top_right = (center[0] + cap_width / 2, center[1] - cap_height / 2)
    bottom_left = (center[0] - cap_width / 2, center[1] + cap_height / 2)
    bottom_right = (center[0] + cap_width / 2, center[1] + cap_height / 2)

    draw.polygon([top_left, top_right, bottom_right, bottom_left], fill=color)

    button_size = size * 0.1
    button_center = (center[0], center[1] - cap_height / 2)
    draw.ellipse(
        (
            button_center[0] - button_size / 2,
            button_center[1] - button_size / 2,
            button_center[0] + button_size / 2,
            button_center[1] + button_size / 2,
        ),
        fill=color,
    )

    tassel_start = (center[0] + cap_width / 4, center[1] - cap_height / 2)
    tassel_control = (center[0] + cap_width / 2, center[1])
    tassel_end = (center[0] + cap_width / 2, center[1] + tassel_length / 2)
    for i in range(3):
        offset = i - 1
        points = [
            tassel_start,
            (tassel_control[0] + offset, tassel_control[1]),
            (tassel_end[0] + offset, tassel_end[1]),
        ]
        draw.line(points, fill=color, width=3)

    check_start = (center[0] - cap_width / 4, center[1])
    check_middle = (center[0], center[1] + cap_height / 3)
    check_end = (center[0] + cap_width / 3, center[1] - cap_height / 4)
    draw.line([check_start, check_middle, check_end], fill=color, width=int(size / 15))


def draw_icon(size: int) -> Image.Image:
    # Black background (RGB) as per user’s reference
    image = Image.new("RGB", (size, size), color="black")
    draw = ImageDraw.Draw(image)

    # Optional squircle container (kept black to match background; uncomment if needed)
    # padding = size * 0.10
    # corner_radius = int(size * 0.2)
    # create_rounded_rectangle(draw, [(padding, padding), (size - padding, size - padding)], corner_radius, "black")

    # Graduation cap with integrated check
    center = (size / 2, size / 2)
    cap_size = size * 0.6
    draw_graduation_cap(draw, center, cap_size, "white")
    return image


def write_contents_json(appiconset_dir: Path) -> None:
    # macOS icon set entries
    entries = [
        {"size": "16x16", "scale": "1x", "idiom": "mac", "filename": "icon_16x16.png"},
        {"size": "16x16", "scale": "2x", "idiom": "mac", "filename": "icon_16x16@2x.png"},
        {"size": "32x32", "scale": "1x", "idiom": "mac", "filename": "icon_32x32.png"},
        {"size": "32x32", "scale": "2x", "idiom": "mac", "filename": "icon_32x32@2x.png"},
        {"size": "128x128", "scale": "1x", "idiom": "mac", "filename": "icon_128x128.png"},
        {"size": "128x128", "scale": "2x", "idiom": "mac", "filename": "icon_128x128@2x.png"},
        {"size": "256x256", "scale": "1x", "idiom": "mac", "filename": "icon_256x256.png"},
        {"size": "256x256", "scale": "2x", "idiom": "mac", "filename": "icon_256x256@2x.png"},
        {"size": "512x512", "scale": "1x", "idiom": "mac", "filename": "icon_512x512.png"},
        {"size": "512x512", "scale": "2x", "idiom": "mac", "filename": "icon_512x512@2x.png"},
    ]
    data = {"images": entries, "info": {"version": 1, "author": "xcode"}}
    (appiconset_dir / "Contents.json").write_text(json.dumps(data, indent=2))


def main() -> None:
    repo_root = Path(__file__).resolve().parents[2]
    appiconset = repo_root / "PhdApply" / "Assets.xcassets" / "AppIcon.appiconset"
    ensure_dir(appiconset)

    # Generate PNGs at all required sizes
    sizes = {
        16: "icon_16x16.png",
        32: "icon_16x16@2x.png",  # 16@2x
        32: "icon_32x32.png",
    }
    # Build the full mapping carefully to avoid duplicate keys
    outputs = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
        (1024, "icon_512x512@2x.png"),
    ]

    for px, name in outputs:
        img = draw_icon(px)
        out_path = appiconset / name
        img.save(out_path, format="PNG")

    write_contents_json(appiconset)
    print(f"Wrote icons to {appiconset}")


if __name__ == "__main__":
    main()


