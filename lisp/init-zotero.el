;;; init-zotero.el --- OpenRouter AI Integration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:



(use-package zotero-query
  :straight (:host github :repo "whacked/zotero-query.el"
                   :files ("*.el" "external" "resources"))
  :commands (zotero-query))

(provide 'init-ai)
;;; init-zotero.el ends here
