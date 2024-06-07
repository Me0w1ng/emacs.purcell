;;; init-python.el --- Python editing -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; I use nix + direnv instead of virtualenv/pyenv/pyvenv, and it is an
;; approach which extends to other languages too. I recorded a
;; screencast about this: https://www.youtube.com/watch?v=TbIHRHy7_JM


(setq auto-mode-alist
      (append '(("SConstruct\\'" . python-mode)
                ("SConscript\\'" . python-mode))
              auto-mode-alist))

(setq python-shell-interpreter "python3")

(require-package 'pip-requirements)

(when (maybe-require-package 'flymake-ruff)
  (defun sanityinc/flymake-ruff-maybe-enable ()
    (when (executable-find "ruff")
      (flymake-ruff-load)))
  (add-hook 'python-mode-hook 'sanityinc/flymake-ruff-maybe-enable))

(maybe-require-package 'ruff-format)

(when (maybe-require-package 'toml-mode)
  (add-to-list 'auto-mode-alist '("poetry\\.lock\\'" . toml-mode)))

(when (maybe-require-package 'jinja2-mode)
  (add-to-list 'auto-mode-alist '(".j2\\.jinja2\\'". jinja2-mode)))

(when (maybe-require-package 'reformatter)
  (reformatter-define black :program "black" :args '("-")))

;; Configure pytest for testing
(use-package pytest
  :ensure t)

;; Virtualenv / Poetry virtual environment Setup
(use-package poetry
  :ensure t)

(defun my-activate-poetry-venv ()
  (interactive)
  (if (file-exists-p "pyproject.toml")
      (progn
        (poetry-venv-workon)
        (message "Activated Poetry virtual environment"))
    (message "No pyproject.toml found")))

;; Configure key binding for activating Poetry virtual environment
(global-set-key (kbd "C-c p") 'my-activate-poetry-venv)

;; Configure Python mode to use Poetry virtual environment
(defun my-configure-poetry-python ()
  (pyvenv-mode 1)
  (pyvenv-tracking-mode 1)
  (poetry-venv-activate)
  (setq-local flycheck-python-pycompile-executable "poetry run python")
  (setq-local python-shell-interpreter "poetry run python"))


(with-eval-after-load 'python-mode
  (add-to-list 'eglot-server-programs '(python-mode . ("pylsp")))
  (add-hook 'python-mode-hook 'eglot-ensure)
  (add-hook 'pyhton-mode-hook 'flycheck-mode)
  (add-hook 'python-mode-hook 'my-configure-poetry-python)
  (setq python-test-runner 'poetry)
  (add-hook 'python-mode-hook 'poetry-tracking-mode)
  (add-hook 'python-mode-hook 'poetry-shell-mode)
  (add-hook 'python-mode-hook 'poetry-project-mode))

(with-eval-after-load 'jinja2-mode
  (add-to-list 'eglot-server-programs '(jinja2-mode . ("jinja2-language-server")))
  (add-hook 'jinja2-mode-hook 'eglot-ensure)
  (add-hook 'jinja2-mode-hook 'flycheck-mode))

; (use-package pyvenv
;   :ensure t
;   :config
;   (pyvenv-mode t)

;   ;; Set correct Python interpreter
;   (setq pyvenv-post-activate-hooks
;         (list (lambda ()
;                 (setq python-shell-interpreter (concat pyvenv-virtual-env "bin/python")))))
;   (setq pyvenv-post-deactivate-hooks
;         (list (lambda ()
;                 (setq python-shell-interpreter "python3")))))

(provide 'init-python)
;;; init-python.el ends here
