"""LessonTracker placeholder asset generator (0.2).

Generates:
- assets/images/app_icon.png       (1024x1024 launcher icon)
- assets/images/splash_logo.png    (512x512 light splash logo, transparent bg)
- assets/images/splash_logo_dark.png (512x512 dark splash logo)

Design: rounded background with a stylized book + checkmark glyph
(LessonTracker: course tracking + smart attendance).
Replace with real design assets when available.
"""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "images"
OUT.mkdir(parents=True, exist_ok=True)

BRAND_PRIMARY = (88, 80, 236)       # deep indigo
BRAND_ACCENT = (255, 255, 255)      # white glyph
BRAND_DARK_BG = (26, 26, 26)        # dark surface for dark splash

BOOK_TOP = (110, 100, 255)          # lighter indigo for top edge
CHECK = (88, 220, 160)              # subtle check accent


def rounded_rect(draw, xy, radius, fill, outline=None, width=1):
    if outline is not None:
        draw.rounded_rectangle(xy, radius=radius, outline=outline, width=width)
    else:
        draw.rounded_rectangle(xy, radius=radius, fill=fill)


def rounded_rect_outline(draw, xy, radius, outline, width):
    draw.rounded_rectangle(xy, radius=radius, outline=outline, width=width)


def draw_book(draw, cx, cy, size, glyph_color, accent_color):
    half = size // 2
    left = cx - half
    top = cy - half
    right = cx + half
    bottom = cy + half
    radius = size // 12

    # Book cover (back)
    rounded_rect(
        draw,
        (left, top, right, bottom),
        radius=radius,
        fill=glyph_color,
    )

    # Page top edge highlight
    top_strip_h = max(2, size // 24)
    rounded_rect(
        draw,
        (left + size // 12, top + size // 14,
         right - size // 12, top + size // 14 + top_strip_h),
        radius=top_strip_h // 2,
        fill=accent_color,
    )

    # Spine line
    spine_x = cx
    draw.line(
        [(spine_x, top + size // 14), (spine_x, bottom - size // 14)],
        fill=accent_color,
        width=max(2, size // 64),
    )

    # Check mark on right page
    check_box = [
        left + size * 0.58, top + size * 0.50,
        left + size * 0.58 + size // 8, top + size * 0.50 + size // 8,
    ]
    draw.rectangle(check_box, outline=accent_color, width=max(2, size // 48))


def make_app_icon():
    size = 1024
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    radius = size // 5
    rounded_rect(draw, (0, 0, size - 1, size - 1), radius=radius, fill=BRAND_PRIMARY)

    # Subtle inner ring
    ring_inset = size // 24
    rounded_rect_outline(
        draw,
        (ring_inset, ring_inset, size - ring_inset - 1, size - ring_inset - 1),
        radius=radius - ring_inset,
        outline=(255, 255, 255, 30),
        width=max(2, size // 96),
    )

    # Book glyph
    draw_book(
        draw,
        cx=size // 2,
        cy=size // 2,
        size=int(size * 0.55),
        glyph_color=BRAND_ACCENT,
        accent_color=BOOK_TOP,
    )

    img.save(OUT / "app_icon.png", "PNG", optimize=True)


def make_splash_logo(dark=False):
    size = 512
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    glyph = (230, 230, 240) if dark else BRAND_PRIMARY
    accent = BRAND_ACCENT if dark else BOOK_TOP

    draw_book(
        draw,
        cx=size // 2,
        cy=size // 2,
        size=int(size * 0.7),
        glyph_color=glyph,
        accent_color=accent,
    )

    name = "splash_logo_dark.png" if dark else "splash_logo.png"
    img.save(OUT / name, "PNG", optimize=True)


if __name__ == "__main__":
    make_app_icon()
    make_splash_logo(dark=False)
    make_splash_logo(dark=True)
    for p in sorted(OUT.iterdir()):
        print(f"{p.name}: {p.stat().st_size} B")