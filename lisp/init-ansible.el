;; Install ansible and yaml-mode packages
(use-package ansible
  :ensure t)

(use-package yaml-mode
  :ensure t
  :mode ("\\.yml\\'" "\\.yaml\\'"))

;; Enable ansible-vault mode
(use-package ansible-vault
  :ensure t)

;; Enable ansible-doc mode
(use-package ansible-doc
  :ensure t
  :hook (yaml-mode . ansible-doc-mode))

;; Enable ansible-lint integration
(use-package flycheck
  :ensure t
  :hook (yaml-mode . flycheck-mode)
  :config
  (flycheck-add-mode 'yaml-yamllint 'yaml-mode)
  (flycheck-add-next-checker 'yaml-yamllint 'ansible-lint))

;; Set up keybindings for ansible-mode and ansible-vault-mode
(with-eval-after-load 'ansible
  (define-key ansible-key-map (kbd "C-c C-d") 'ansible-doc))

;; Set up indentation for yaml-mode ;; Enable ansible-lint on save ;; Enable ansible-vault-mode on encrypted files
(add-hook 'yaml-mode-hook
          (lambda ()
            (setq-local indent-tabs-mode nil)
            (setq-local yaml-indent-offset 2)
            (add-hook 'before-save-hook 'ansible-lint nil 'local)
            (when (and buffer-file-name
                       (string-match-p "\\.vault\\.yml\\'" buffer-file-name))
              (ansible-vault-mode 1))))

(provide 'init-ansible)
;;; init-ansible.el ends here