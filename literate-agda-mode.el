;;; markdown-agda-mode.el --- Major mode for working with literate markdown agda files
;;; -*- lexical-binding: t

;;; Commentary:

;; A major mode for editing Agda code embedded in markdown files (.lagda.md files.)
;; https://agda.readthedocs.io/en/v2.6.1/tools/literate-programming.html#literate-org

;;; Code:

(require 'polymode)
(require 'agda2-mode)
(require 'tex)

(defgroup literate-agda-mode nil
  "markdown-agda-mode customisations"
  :group 'languages)

(defcustom use-agda-input t
  "Whether to use Agda input mode in non-Agda parts of the file."
  :group 'literate-agda-mode
  :type 'boolean)

(define-hostmode poly-literate-agda-hostmode
  :mode 'LaTeX-mode
  :protect-font-lock t
  :protect-syntax t
  :keep-in-mode 'host)

(define-innermode poly-literate-agda-innermode
  :mode 'agda2-mode
  :head-matcher "\\begin{code}"
  :tail-matcher "\\end{code}"
  ;; Keep the code block wrappers in markdown mode, so they can be folded, etc.
  :head-mode 'LaTeX-mode
  :tail-mode 'LaTeX-mode
  ;; Disable font-lock-mode, which interferes with Agda annotations,
  ;; and undo the change to indent-line-function Polymode makes.
  :init-functions '((lambda (_) (let ((span (pm-innermost-range))
				      (beg (car span))
				      (end (cdr span)))
				  (remove-text-properties beg end '(face nil))))
                    (lambda (_) (setq indent-line-function #'indent-relative))))

(define-polymode literate-agda-mode
  :hostmode 'poly-literate-agda-hostmode
  :innermodes '(poly-literate-agda-innermode)
  (when use-agda-input (set-input-method "Agda")))

(assq-delete-all 'background agda2-highlight-faces)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.lagda.tex\\'" . literate-agda-mode))

(provide 'literate-agda-mode)
;;; markdown-agda-mode ends here
