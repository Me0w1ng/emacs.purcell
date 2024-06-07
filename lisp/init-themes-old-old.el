;;; init-themes.el --- Defaults for themes -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; theme switching stuff from https://www.greghendershott.com/2017/02/emacs-themes.html
(defun yalaoui/disable-all-themes ()
  (interactive)
  (mapc #'disable-theme custom-enabled-themes))

(defvar yalaoui/theme-hooks nil
  "((theme-id . function) ...)")

(defun yalaoui/add-theme-hook (theme-id hook-func)
  (add-to-list 'yalaoui/theme-hooks (cons theme-id hook-func)))

(defun yalaoui/load-theme-advice (f theme-id &optional no-confirm no-enable &rest args)
  "Enhance `load-theme' by disabling other enabled themes & calling hooks"
  (unless no-enable
    (yalaoui/disable-all-themes))
  (prog1
      (apply f theme-id no-confirm no-enable args)
    (unless no-enable
      (pcase (assq theme-id yalaoui/theme-hooks)
        (`(,_ . ,f) (funcall f))))))

(advice-add 'load-theme :around #'yalaoui/load-theme-advice)

(use-package modus-themes
  :defer t
  :custom
  ((modus-themes-bold-constructs t)
   (modus-themes-italic-constructs t)
   (modus-themes-slanted-constructs t)
   (modus-themes-completions '((matches . (background intense))
                               (selection . (accented intense))
                               (popup . (accented intense))))
   (modus-themes-org-blocks 'rainbow)
   (modus-themes-headings '((t . (overline background variable-pitch))))
   (modus-themes-variable-pitch-headings t)))

(when (maybe-require-package 'ef-themes)
  (setopt ef-themes-mixed-fonts t
          ef-themes-variable-pitch-ui t)
  (setopt ef-themes-headings '((1 . (semibold))
                               (t . (variable-pitch))))
  (set-face-attribute 'mode-line nil :family "PragmataPro")
  (set-face-attribute 'mode-line-inactive nil :family "PragmataPro"))

(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (mouse-wheel-mode t)
  (blink-cursor-mode -1))

(global-display-line-numbers-mode)
(defun yalaoui/display-line-numbers-turn-off ()
  (display-line-numbers-mode -1))
(add-hook 'image-mode-hook #'yalaoui/display-line-numbers-turn-off)

(show-paren-mode 1)

(when (maybe-require-package 'nyan-mode)
  (nyan-mode 1)
  (setq nyan-bar-length 16
        nyan-wavy-trail nil))


(when (maybe-require-package 'cyphejor)
  (setq cyphejor-rules
        '(("mode" "")
          ("haskell" "")
          ("emacs" "")
          ("sh" "")
          ("ruby" "")
          ("magit" "")
          ("clojure" "")
          ("markdown" "")
          ("js2" "")
          ("sql" "")
          ("dired" "")
          ("eshell" "")
          ("html" "")
          ("rust" "")
          ("swift" "")
          ("erlang" "")
          ("elixir" "")
          ("alchemist" "")
          ("erc" "")
          ("notmuch" "")
          ("prolog" "")
          ("python" "")
          ("web" "")
          ("conf" "")))
  (cyphejor-mode 1))

;; Handle ANSI colours in compile buffer output.
;; From https://gist.github.com/jwiegley/8ae7145ba5ce64250a05
(defun compilation-ansi-color-process-output ()
  (ansi-color-process-output nil)
  (set (make-local-variable 'comint-last-output-start)
       (point-marker)))
(add-hook 'compilation-filter-hook #'compilation-ansi-color-process-output)

(with-eval-after-load 'dash (dash-enable-font-lock))

(cond
 ((member "Noto Color Emoji" (font-family-list))
  (set-fontset-font t 'unicode "Noto Color Emoji" nil 'prepend))
 ((member "Apple Color Emoji" (font-family-list))
  (set-fontset-font t 'unicode "Apple Color Emoji" nil 'prepend))
 ((member "FSD Emoji" (font-family-list))
  (set-fontset-font t 'unicode "FSD Emoji" nil 'prepend))
 ((member "Symbola" (font-family-list))
  (set-fontset-font t 'unicode "Symbola" nil 'prepend)))


(when (maybe-require-package 'svg-tag-mode))

;; (modus-themes-load-themes)
;; (modus-themes-load-operandi)
(load-theme 'ef-spring)


(provide 'init-themes)
;;; init-themes.el ends here
