#!/usr/bin/env python3
"""Generate the Xzifra launcher icon assets.

The X mark is derived from Lucide's "x" icon (ISC, derived from Feather/MIT).
See app/assets/icon/LICENSE-lucide.txt for the full notice.

Usage:
    python3 scripts/generate_icon.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "app" / "assets" / "icon"

SIZE = 1024
SUPERSAMPLE = 4

INDIGO = (79, 70, 229, 255)  # #4F46E5, the app seed color
WHITE = (255, 255, 255, 255)
LIGHT_BG = (245, 245, 247, 255)
DARK_BG = (17, 17, 20, 255)
PASTEL = (232, 222, 248, 255)
INK = (30, 30, 35, 255)

FONT_REGULAR = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"


def render_mark(
    *,
    span: int,
    stroke: int,
    rule_alpha: float,
    background: tuple[int, int, int, int] | None = None,
) -> Image.Image:
    """Render the X plus ledger rules, optionally on a solid background."""
    canvas = SIZE * SUPERSAMPLE
    scale = canvas / SIZE
    mark = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    draw = ImageDraw.Draw(mark)

    center = canvas / 2
    half = span * scale / 2
    line_width = max(1, int(round(stroke * scale)))
    rule_width = max(1, int(round(stroke * 0.14 * scale)))

    # Two ledger rules behind the X.
    rule_half = half * 0.82
    rule_alpha_value = int(round(255 * rule_alpha))
    for offset in (-0.30, 0.30):
        y = center + offset * span * scale
        draw.line(
            [(center - rule_half, y), (center + rule_half, y)],
            fill=(255, 255, 255, rule_alpha_value),
            width=rule_width,
        )

    # Lucide "x" geometry: M18 6 L6 18 and M6 6 L18 18.
    cap_radius = line_width / 2
    for x1, y1, x2, y2 in (
        (center + half, center - half, center - half, center + half),
        (center - half, center - half, center + half, center + half),
    ):
        draw.line([(x1, y1), (x2, y2)], fill=WHITE, width=line_width)
        for px, py in ((x1, y1), (x2, y2)):
            draw.ellipse(
                [
                    px - cap_radius,
                    py - cap_radius,
                    px + cap_radius,
                    py + cap_radius,
                ],
                fill=WHITE,
            )

    mark = mark.resize((SIZE, SIZE), Image.LANCZOS)
    if background is None:
        return mark

    base = Image.new("RGBA", (SIZE, SIZE), background)
    base.alpha_composite(mark)
    return base


def circle_mask(size: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    return mask


def panel(
    sheet: Image.Image,
    image: Image.Image,
    box: tuple[int, int, int, int],
    *,
    background: tuple[int, int, int, int] | None = None,
    rounded: bool = True,
) -> None:
    x, y, width, height = box
    if background is not None:
        layer = Image.new("RGBA", (width, height), background)
        if rounded:
            radius = 56
            mask = Image.new("L", (width, height), 0)
            ImageDraw.Draw(mask).rounded_rectangle(
                (0, 0, width - 1, height - 1), radius=radius, fill=255
            )
            layer.putalpha(mask)
        sheet.alpha_composite(layer, (x, y))

    icon = image.resize((width, height), Image.LANCZOS)
    sheet.alpha_composite(icon, (x, y))


def build_preview(
    icon: Image.Image, foreground: Image.Image, monochrome: Image.Image
) -> None:
    width, height = 1400, 1000
    sheet = Image.new("RGBA", (width, height), LIGHT_BG)
    draw = ImageDraw.Draw(sheet)
    title = ImageFont.truetype(FONT_BOLD, 32)
    label = ImageFont.truetype(FONT_REGULAR, 22)
    note = ImageFont.truetype(FONT_REGULAR, 18)

    draw.text((40, 28), "Xzifra icon — variant A", font=title, fill=INK)

    size = 300
    y = 100
    positions = [40, 380, 720, 1060]

    # 1. Legacy icon on a light surface.
    panel(sheet, icon, (positions[0], y, size, size), background=(255, 255, 255, 255))
    draw.text((positions[0], y + size + 16), "Legacy · light", font=label, fill=INK)

    # 2. Legacy icon on a dark surface.
    panel(sheet, icon, (positions[1], y, size, size), background=DARK_BG)
    draw.text((positions[1], y + size + 16), "Legacy · dark", font=label, fill=INK)

    # 3. Adaptive foreground clipped by a circular launcher mask.
    adaptive = Image.new("RGBA", (size, size), INDIGO)
    adaptive.alpha_composite(foreground.resize((size, size), Image.LANCZOS))
    adaptive.putalpha(circle_mask(size))
    sheet.alpha_composite(adaptive, (positions[2], y))
    draw.text(
        (positions[2], y + size + 16),
        "Adaptive · circle mask",
        font=label,
        fill=INK,
    )

    # 4. Monochrome layer tinted like an Android 13 themed icon.
    themed = Image.new("RGBA", (size, size), PASTEL)
    tint = Image.new("RGBA", (size, size), INDIGO)
    themed.paste(tint, (0, 0), monochrome.resize((size, size), Image.LANCZOS))
    themed.putalpha(circle_mask(size))
    sheet.alpha_composite(themed, (positions[3], y))
    draw.text(
        (positions[3], y + size + 16),
        "Monochrome · themed",
        font=label,
        fill=INK,
    )

    # Small sizes, as they appear in a launcher or search result.
    draw.text((40, 520), "Small sizes", font=title, fill=INK)
    x = 40
    for small in (48, 72, 96, 144, 192):
        small_icon = icon.resize((small, small), Image.LANCZOS)
        sheet.alpha_composite(small_icon, (x, 590))
        draw.text((x, 590 + small + 10), f"{small} px", font=note, fill=INK)
        x += small + 48

    draw.text(
        (40, 920),
        "Mark derived from Lucide 'x' (ISC, Feather/MIT) · background #4F46E5",
        font=note,
        fill=(110, 110, 120, 255),
    )

    sheet.convert("RGB").save(OUT / "preview.png", quality=95)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    icon = render_mark(span=620, stroke=80, rule_alpha=0.26, background=INDIGO)
    foreground = render_mark(span=560, stroke=72, rule_alpha=0.28)
    monochrome = render_mark(span=560, stroke=72, rule_alpha=0.32)

    icon.save(OUT / "icon.png")
    foreground.save(OUT / "icon_foreground.png")
    monochrome.save(OUT / "icon_monochrome.png")
    build_preview(icon, foreground, monochrome)

    print(f"Wrote icon assets to {OUT}")


if __name__ == "__main__":
    main()
