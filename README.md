# yk-color
Elisp library for linear RGB color manipulation

* Usage

	(require 'yk-color "/path/to/yk-color.el")

	or

	(use-packege yk-color
	  :load-path "/path/tp/[yk-color.el]")

## sRGB ↔ linear RGB conversion

* **yk-color-srgb-to-rgb** (c)

Convert a color component value from sRGB to linear RGB.

C should be between 0.0 and 1.0, inclusive.

* **yk-color-rgb-to-srgb** (c)

Convert a color component value from linear RGB to sRGB.

C should be between 0.0 and 1.0, inclusive.

* **yk-color-to-rgb** (color)

Return linear normalized RGB components of the named color.

* **yk-color-from-rgb** (rgb)

Return a hex string representation of a linear RGB color.

RGB must be a list (R G B) with components between 0.0 and 1.0, inclusive.

## Color Blending

* **yk-color-blend--1** (c1 alpha2 c2)

Blend two color component values.

Return (1-alpha2)*c**1 + alpha2*c2.

* **yk-color-blend-rgb** (rgb1 alpha2 rgb2)

Blend two colors.

RGB1 and RGB2 must be lists (R G B),

with each component between 0.0 and 1.0 inclusive, linear RGB space.

Return value will have the same format.



ALPHA2 specifies RGB2’s coefficient in the blend;

invoking (yk-color-blend-rgb rgb1 1.0 rgb2) will return rgb2.

* **yk-color-blend** (color1 alpha2 color2)

Blend two colors.

COLOR1 and COLOR2 should be color names. sRGB color space is assumed.

Return a hex (#rrggbb) string.

## WCAG color metrics

* **yk-color-relative-luminance-rgb** (rgb)

Calculate relative luminance of a color, as defined by WCAG 2.0.

RGB must be a list (R G B)

with all components between 0.0 and 1.0 inclusive, linear RGB.

* **yk-color-contrast-ratio-rgb** (rgb1 rgb2)

Calculate contrast ratio between two colors, as defined by WCAG 2.0.

All color components must be between 0.0 and 1.0 inclusive, linear RGB.

* **yk-color-contrast-ratio** (color1 color2)

Calculate contrast ratio between two named colors.

* **yk-color-adjust-rgb** (rgb0 cr rgb1 rgb2 &optional down)

Find a color between RGB1 and RGB2 giving the specified contrast ratio to RGB0.

All colors must be in linear RGB space, with components between 0.0 and 1.0, inclusive.

RGB1 and RGB2 should be roughly the same hue, different luminance,

preferably, one darker than the desired result, the other lighter.


There are two potential solutions, one brighter than RGB0, the other darker.

If DOWN is non-nil, return the darker one; otherwise, the lighter one.

Return nil if the specified solution does not exist.

* **yk-color-adjust** (color0 cr color1 color2 &optional down)
