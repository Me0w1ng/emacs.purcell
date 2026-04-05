;;; init-ai.el --- OpenRouter AI Integration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'auth-source)
(require 'org-clock)
(require 'epa-file)





;; ================= AUTHENTICATION & GPG =================
;; Cache the GPG passphrase for symmetric encryption
(setq epa-file-cache-passphrase-for-symmetric-encryption t)
;; Enable verbose logging for auth-source diagnostics (check *Messages*)
(setq auth-source-debug t)
;; Force Emacs to prompt for passwords in the minibuffer instead of GUI pinentry
(setq epa-pinentry-mode 'loopback)
;; Define GPG-encrypted authinfo file as the sole credential source
(setq auth-sources '("~/.authinfo.gpg"))
;; Enable EPA file handling for transparent GPG decryption
(epa-file-enable)





;; ================= HELPER FUNCTIONS =================
;; Helper to pull AI API keys from GPG-encrypted authinfo
(defun my/get-ai-key (host)
  "Retrieve the secret for HOST from auth-source."
  (let ((match (auth-source-search :host host :user "apikey" :require '(:secret))))
    (if match
        (let ((secret (plist-get (car match) :secret)))
          (if (functionp secret) (funcall secret) secret))
      (error "Could not find apikey for %s in ~/.authinfo.gpg" host))))





;; ================= TERMINAL BACKEND =================
(require-package 'vterm)
(use-package vterm
  :ensure t
  :config
  ;; Always compile the vterm module on load/update
  (setq vterm-always-compile-module t))





;; ================= LLM CLIENT (GPTEL) =================
(use-package gptel
  :ensure t
  ;; ================= KEYBINDINGS =================
  :bind (("C-c g t" . gptel-send)
         ("C-c g m" . gptel-menu)
         ("C-c g b" . gptel))
  :config
  ;; ================= CORE BACKEND =================
  (setq gptel-backend
        (gptel-make-openai "OpenRouter"
          :host "openrouter.ai"
          :endpoint "/api/v1/chat/completions"
          :stream t
          :key (lambda () (my/get-ai-key "openrouter.ai"))
          ;; List of available models
          :models '("qwen/qwen3.6-plus:free"
                    "google/gemini-pro-1.5")))

  ;; ================= DEFAULTS & CONTEXT =================
  ;; Set the default model (must match exactly one in the :models list above)
  (setq-default gptel-model "qwen/qwen3.6-plus:free")
  ;; Enable branching context tracking for Org mode
  (setq gptel-org-branching-context t))





;; ================= AI CODING ASSISTANT (AIDERMACS) =================
;; https://aider.chat/docs/install/optional.html
;; https://aider.chat/docs/usage.html
(require-package 'aidermacs)
(use-package aidermacs
  :ensure t
  ;; ================= KEYBINDINGS =================
  :bind (("C-c C-a r" . aidermacs-run)
         ;; Transient menu recommended for faster access to all commands
         ("C-c C-a a" . aidermacs-transient-menu))
  :config
  ;; ================= CORE =================
  (setq aidermacs-backend 'vterm)      ; Use vterm as the terminal backend
  (setq aidermacs-program "aider")     ; Executable name (adjust if in a venv/path)

  ;; ================= MODEL CONFIG =================
  (setq aidermacs-main-model      "openrouter/qwen/qwen3.6-plus:free") ; Primary coding model
  (setq aidermacs-weak-model      "openrouter/qwen/qwen3.6-plus:free") ; Commit messages & summaries
  (setq aidermacs-architect-model "openrouter/qwen/qwen3.6-plus:free") ; High-level planning & refactoring

  ;; [UNUSED] Raw CLI override (kept for reference)
  ;; (setq aidermacs-args '("--model" "openrouter/qwen/qwen3.6-plus:free"))

  ;; ================= BEHAVIOR & MODES =================
  (setq aidermacs-default-chat-mode 'architect)   ; Best for complex refactoring
  (setq aidermacs-auto-commits nil)               ; Manual review before committing
  (setq aidermacs-auto-accept-architect nil)      ; Manual approval in architect mode
  (setq aidermacs-subtree-only t)                 ; Scope limiter for monorepos/large trees
  (setq aidermacs-exit-kills-buffer t)            ; Auto-cleanup buffer on session end

  ;; ================= UI & REVIEW =================
  (setq aidermacs-use-ediff t) ; Highly recommended: diff AI changes using Emacs Ediff

  ;; ================= ADVANCED / UNUSED =================
  ;; External YAML config (overrides most Emacs variables if set)
  ;; (setq aidermacs-config-file "~/.aider.conf.yml")
  ;; Pass arbitrary CLI flags directly to the aider process
  ;; (setq aidermacs-extra-args '("--dark-mode"))

  ;; ================= AUTHENTICATION =================
  ;; Export API key to environment for aider CLI
  (setenv "OPENROUTER_API_KEY" (my/get-ai-key "openrouter.ai")))




(provide 'init-ai)
;;; init-ai.el ends here
