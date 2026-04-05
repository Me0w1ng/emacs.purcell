;;; init-ai.el --- OpenRouter AI Integration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'auth-source)
(require 'org-clock)

;; (setq epa-file-cache-passphrase-for-symmetric-encryption t)
;; (setq epa-file-cache-passphrase-for-symmetric-encryption t) ; Cache the pass
(setq auth-source-debug t) ; Helps us see what's happening in *Messages*
(setq epa-pinentry-mode 'loopback) ; Force Emacs to ask for password in the minibuffer

(setq auth-sources '("~/.authinfo.gpg"))
(require 'epa-file)
(epa-file-enable)



;; 1. Helper to pull the key from your GPG-encrypted authinfo ~/.authinfo.gpg
(defun my/get-ai-key (host)
  "Retrieve the secret for HOST from auth-source."
  (let ((match (auth-source-search :host host :user "apikey" :require '(:secret))))
    (if match
        (let ((secret (plist-get (car match) :secret)))
          (if (functionp secret) (funcall secret) secret))
      (error "Could not find apikey for %s in ~/.authinfo.gpg" host))))


;; 2. Vterm Setup
(require-package 'vterm)
(use-package vterm
  :ensure t
  :config (setq vterm-always-compile-module t))



;; 3. GPTel Configuration (Optimized for OpenRouter)
(use-package gptel
  :ensure t
  :bind (("C-c g t" . gptel-send)
         ("C-c g m" . gptel-menu)
         ("C-c g b" . gptel))
  :config
  (setq gptel-backend
        (gptel-make-openai "OpenRouter"
          :host "openrouter.ai"
          :endpoint "/api/v1/chat/completions"
          :stream t
          :key (lambda () (my/get-ai-key "openrouter.ai"))
          ;; 1. Add a quote here: '
          ;; 2. Remove "openrouter/" from the string
          :models '("qwen/qwen3.6-plus:free"
                    "google/gemini-pro-1.5")))

  ;; Match the string exactly as it appears in the :models list above
  (setq-default gptel-model "qwen/qwen3.6-plus:free")
  (setq gptel-org-branching-context t))


;; 4. Aidermacs Configuration
(require-package 'aidermacs)
(use-package aidermacs
  :ensure t
  :bind (("C-c C-a r" . aidermacs-run)
         ("C-c C-a a" . aidermacs-add-current-file))
  :config
  ;; Note the specific OpenRouter model string
  (setq aidermacs-args '("--model" "openrouter/qwen/qwen3.6-plus:free"))
  (setq aidermacs-backend 'vterm)
  ;; CRITICAL: Aider needs OPENROUTER_API_KEY for these models
  (setenv "OPENROUTER_API_KEY" (my/get-ai-key "openrouter.ai")))


;; (use-package aidermacs
;;   :ensure t
;;   :bind (("C-c C-a a" . aidermacs-transient-menu)
;;          ("C-c C-a r" . aidermacs-run))
;;   :config
;;   ;; --- TERMINAL & PROCESS ---

;;   ;; The backend to use. Options: 'vterm (recommended) or 'comint.
;;   (setq aidermacs-backend 'vterm)

;;   ;; Path to the aider executable. Can be a string "aider" or a list of fallbacks.
;;   (setq aidermacs-program "aider")

;;   ;; If non-nil, killing the aider session also kills the associated buffer.
;;   (setq aidermacs-exit-kills-buffer t)

;;   ;; --- MODEL CONFIGURATION ---

;;   ;; The main model used for coding.
;;   ;; For OpenRouter, use strings like "openrouter/anthropic/claude-3.5-sonnet`'
;;   ;; The model used specifically for commit messages and chat summarization.
;;   ;; Using a "weaker" (cheaper/faster) model here saves money.
;;   (setq aidermacs-weak-model "openrouter/qwen/qwen3.6-plus:free")

;;   ;; In "Architect Mode", this is the high-level reasoning model.
;;   (setq aidermacs-architect-model "openrouter/qwen/qwen3.6-plus:free")

;;   ;; --- BEHAVIOR & MODES ---

;;   ;; Default chat mode. Options: nil (Code), 'ask, 'architect, or 'help.
;;   ;; 'architect is highly recommended for complex refactoring.
;;   (setq aidermacs-default-chat-mode 'architect)

;;   ;; Aider normally commits every change automatically.
;;   ;; Aidermacs disables this by default (nil) so you can review changes first.
;;   (setq aidermacs-auto-commits nil)

;;   ;; If using Architect mode, should it automatically apply changes?
;;   (setq aidermacs-auto-accept-architect nil)

;;   ;; Limit aider to the current directory only (useful in monorepos).
;;   (setq aidermacs-subtree-only t)

;;   ;; --- UI & REVIEW ---

;;   ;; Use Emacs' built-in Ediff to review changes made by the AI.
;;   ;; This is one of the best features of the package.
;;   (setq aidermacs-use-ediff t)

;;   ;; --- ADVANCED / CLI ARGUMENTS ---

;;   ;; Path to a specific YAML config file for aider.
;;   ;; If set, it ignores most other variable-based configs.
;;   (setq aidermacs-config-file "~/.aider.conf.yml")

;;   ;; Pass any extra command line arguments directly to the aider process.
;;   ;; Example: '("--no-auto-commits" "--dark-mode")
;;   (setq aidermacs-extra-args '())

;;   ;; --- API KEYS (Environment) ---

;;   ;; Aider looks for these environment variables to authenticate.
;;   (setenv "OPENROUTER_API_KEY" (my/get-ai-key "openrouter.ai")))


(provide 'init-ai)
;;; init-ai.el ends here
