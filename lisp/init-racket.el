;;; init-racket.el --- Racket customisations -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Load racket-mode
(use-package racket-mode
  :ensure t
  :config
  (define-key racket-mode-map (kbd "M-.") 'xref-find-definitions)
  (define-key racket-mode-map (kbd "M-,") 'xref-pop-marker-stack)
  (add-to-list 'auto-mode-alist '("\\.rkt\\'" . racket-mode)))

;; ;; Load Geiser
;; (use-package geiser
;;   :ensure t)

;; ;; Load Quack
;; (use-package quack
;;   :ensure t)

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(racket-mode . ("racket" "--lsp")))
  (add-to-list 'auto-mode-alist '("\\.rkt\\'" . racket-mode))
  (add-hook 'terraform-mode-hook 'eglot-ensure)
  (add-hook 'terraform-mode-hook #'company-mode)
  (add-hook 'terraform-mode-hook #'flycheck-mode))

(provide 'init-racket)
;;; init-racket.el ends here