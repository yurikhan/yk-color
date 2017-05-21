(require 'cl-lib)
(require 'color)

;;; sRGB ↔ linear RGB conversion
;; Formula from <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
(defun yk-color-srgb-to-rgb (c)
  "Convert a color component value from sRGB to linear RGB.
C should be between 0.0 and 1.0, inclusive."
  (if (<= c 0.03928)
      (/ c 12.92)
    (expt (/ (+ c 0.055) 1.055) 2.4)))

;; Formula derived by reversing the above
(defun yk-color-rgb-to-srgb (c)
  "Convert a color component value from linear RGB to sRGB.
C should be between 0.0 and 1.0, inclusive."
  (let ((cc (* c 12.92)))
    (if (<= cc 0.03928)
        cc
      (- (* 1.055 (expt c (/ 1 2.4))) 0.055))))

;;; Color name ↔ linear RGB conversion
(defun yk-color-to-rgb (color)
  "Return linear normalized RGB components of the named color."
  (mapcar 'yk-color-srgb-to-rgb (color-name-to-rgb color)))

(defun yk-color-from-rgb (rgb)
  "Return a hex string representation of a linear RGB color.
RGB must be a list (R G B) with components between 0.0 and 1.0, inclusive."
  (apply 'color-rgb-to-hex (mapcar 'yk-color-rgb-to-srgb rgb)))


;;; Color blending
(defun yk-color-blend--1 (c1 alpha2 c2)
  "Blend two color component values.
Return (1-alpha2)*c1 + alpha2*c2."
  (+ (* c1 (- 1 alpha2)) (* c2 alpha2)))

(defun yk-color-blend-rgb (rgb1 alpha2 rgb2)
  "Blend two colors.
RGB1 and RGB2 must be lists (R G B),
with each component between 0.0 and 1.0 inclusive, linear RGB space.
Return value will have the same format.

ALPHA2 specifies RGB2’s coefficient in the blend;
invoking (yk-color-blend-rgb rgb1 1.0 rgb2) will return rgb2."
  (cl-mapcar (lambda (c1 c2) (yk-color-blend--1 c1 alpha2 c2)) rgb1 rgb2))

(defun yk-color-blend (color1 alpha2 color2)
  "Blend two colors.
COLOR1 and COLOR2 should be color names. sRGB color space is assumed.
Return a hex (#rrggbb) string."
  (let ((rgb1 (yk-color-to-rgb color1))
        (rgb2 (yk-color-to-rgb color2)))
    (yk-color-from-rgb
     (yk-color-blend-rgb rgb1 alpha2 rgb2))))


;;; WCAG color metrics
(defun yk-color-relative-luminance-rgb (rgb)
  "Calculate relative luminance of a color, as defined by WCAG 2.0.
RGB must be a list (R G B)
with all components between 0.0 and 1.0 inclusive, linear RGB."
  (pcase rgb
    (`(,r ,g ,b) (+ (* 0.2126 r) (* 0.7152 g) (* 0.0722 b)))))

(defun yk-color-relative-luminance (color)
  "Calculate relative luminance of the named color."
  (yk-color-relative-luminance (yk-color-to-rgb color)))

(defun yk-color-contrast-ratio-rgb (rgb1 rgb2)
  "Calculate contrast ratio between two colors, as defined by WCAG 2.0.
All color components must be between 0.0 and 1.0 inclusive, linear RGB."
  (let ((l1 (yk-color-relative-luminance-rgb rgb1))
        (l2 (yk-color-relative-luminance-rgb rgb2)))
    (/ (+ (max l1 l2) 0.05)
       (+ (min l1 l2) 0.05))))

(defun yk-color-contrast-ratio (color1 color2)
  "Calculate contrast ratio between two named colors."
  (yk-color-contrast-ratio-rgb (yk-color-to-rgb color1)
                               (yk-color-to-rgb color2)))

;;; Contrast ratio adjustment
(defun yk-color-adjust-rgb (rgb0 cr rgb1 rgb2 &optional down)
  "Find a color between RGB1 and RGB2 giving the specified contrast ratio to RGB0.
All colors must be in linear RGB space, with components between 0.0 and 1.0, inclusive.
RGB1 and RGB2 should be roughly the same hue, different luminance,
preferably, one darker than the desired result, the other lighter.

There are two potential solutions, one brighter than RGB0, the other darker.
If DOWN is non-nil, return the darker one; otherwise, the lighter one.

Return nil if the specified solution does not exist."
  (condition-case error
      (let* ((l1 (yk-color-relative-luminance-rgb rgb1))
             (l2 (yk-color-relative-luminance-rgb rgb2))
             (l0 (yk-color-relative-luminance-rgb rgb0))
             (l (if down
                    (- (/ (+ l0 0.05) cr) 0.05)
                  (- (* (+ l0 0.05) cr) 0.05)))
             (alpha2 (/ (- l l1) (- l2 l1))))
        (and (<= 0.0 l) (<= l 1.0)
             (yk-color-blend-rgb rgb1 alpha2 rgb2)))
    ('arith-error nil)))

(defun yk-color-adjust (color0 cr color1 color2 &optional down)
  (let ((rgb0 (yk-color-to-rgb color0))
        (rgb1 (yk-color-to-rgb color1))
        (rgb2 (yk-color-to-rgb color2)))
    (yk-color-from-rgb
     (yk-color-adjust-rgb rgb0 cr rgb1 rgb2 down))))

(provide 'yk-color)
