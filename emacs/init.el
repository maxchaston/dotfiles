;; GENERAL CONFIG ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set up package.el to work with MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents)

;; Download Evil
(unless (package-installed-p 'evil)
  (package-install 'evil))

;; Enable Evil
(require 'evil)
(evil-mode 1)


;; straight.el init https://github.com/radian-software/straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; racket support for emacs babel
(use-package ob-racket
  :after org
  :config
  (add-hook 'ob-racket-pre-runtime-library-load-hook
	      #'ob-racket-raco-make-runtime-library)
  :straight (ob-racket
	       :type git :host github :repo "hasu/emacs-ob-racket"
	       :files ("*.el" "*.rkt")))

;; enable racket in org-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp :tangle ./init.el . t)
   (C . t)
   (python . t)
   (racket . t)))

;; Make evil-mode up/down operate in screen lines instead of logical lines
(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)

;; Exit insert mode by pressing j and then k quickly
(unless (package-installed-p 'key-chord)
(package-install 'key-chord))
(require 'key-chord)
(key-chord-mode 1)
(setq key-chord-two-keys-delay 0.25)
(key-chord-define evil-insert-state-map "jk" 'evil-normal-state)

;; mozc support for japanese input
(unless (package-installed-p 'mozc)
(package-install 'mozc))
(require 'mozc)  ; or (load-file "/path/to/mozc.el")
(setq default-input-method "japanese-mozc")
(setq mozc-candidate-style 'overlay)
;; unbind mark
(global-unset-key (kbd "C-SPC"))
(global-set-key (kbd "C-SPC") 'toggle-input-method)
;; fix evil mode "jk" bind breaking on toggling mozc
;; (add-hook 'evil-insert-state-entry-hook
;; 					(lambda ()
;; 						(key-chord-mode 1)))
(add-hook 'input-method-deactivate-hook
					(lambda ()
						(key-chord-mode 1)))

;; Disabling default UI elements
(menu-bar-mode -1) 
(scroll-bar-mode -1) 
(tool-bar-mode -1)


;; load pdf-tools
(pdf-tools-install :no-query)
(require 'pdf-tools)
(add-hook 'doc-view-mode-hook 'pdf-tools-install) 

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-dim-other-buffers-face ((t (:background "#303030"))))
 '(org-level-1 ((t (:height 1.5 :extend nil :inherit outline-1))))
 '(org-level-2 ((t (:height 1.25 :foreground "dark goldenrod" :extend nil :inherit outline-2))))
 '(org-level-3 ((t (:height 1.0 :extend nil :inherit outline-3)))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-view-program-selection
   '(((output-dvi has-no-display-manager) "dvi2tty")
     ((output-dvi style-pstricks) "dvips and gv") (output-dvi "xdvi")
     (output-pdf "PDF Tools") (output-html "xdg-open")))
 '(auth-source-save-behavior nil)
 '(custom-enabled-themes '(wombat))
 '(eglot-ignored-server-capabilities '(:documentOnTypeFormattingProvider))
 '(initial-buffer-choice nil)
 '(org-format-latex-options
   '(:foreground default :background default :scale 1.75 :html-foreground
                 "Black" :html-background "Transparent" :html-scale
                 1.0 :matchers ("begin" "$1" "$" "$$" "\\(" "\\[")))
 '(package-selected-packages
   '(sicp racket-mode company windresize hl-todo centered-cursor-mode
          magit astyle platformio-mode ripgrep vterm key-chord
          sudo-edit good-scroll pdf-tools auctex org-download xclip
          mozc lua-mode consult evil))
 '(python-indent-guess-indent-offset nil))

;; Configure org-roam to run file changes to maintain cache consistency
(org-roam-db-autosync-mode)

;; Stop creating those #auto-save# files
(setq auto-save-default nil)

;; Move tilde backups into one folder
(setq backup-directory-alist '(("." . "~/.config/emacs/backup")))

;; Display line numbers in all modes
(global-display-line-numbers-mode)

;; Line wrap in all modes
(global-visual-line-mode)

;; Changes evil undo mode to undo-redo, allowing for redoing in evil mode
(evil-set-undo-system 'undo-redo)

;; set org-roam dailies directory to ~/org-roam/daily/
(setq org-roam-dailies-directory "daily/")

;; Enable consult
(use-package consult)

;; org roam capture template for dailies
(setq org-roam-dailies-capture-templates
  '(("d" "default" entry
     (file "/home/USERCHANGEME/org-roam/templates/daily-template.org")
     :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>")
)))

;; extra TODO keywords
(setq org-todo-keywords
      '((sequence "TODO" "|" "DONE")
	(sequence "IDEA" "|" "DONE")
	(sequence "PROBLEM" "|" "FIXED")
	(sequence "DOING" "|" "DONE")
	(sequence "JOKE")))

;; use org-roam-export overrides for better export support
(require 'org-roam-export)

;; enable xclip-mode to use xclip as a clipboard
(xclip-mode 1)

;; hide emphasis markers so markup like ~code~ or =verbatim= doesn't show up in org mode
(setq org-hide-emphasis-markers t)

;; don't ask to reread from disk when in doc view mode
(add-hook 'doc-view-mode-hook 'auto-revert-mode)
(setq revert-without-query '(".pdf")) ;; above line only worked sometimes for some reason

;; spell checking for org mode
;; (add-hook 'org-mode-hook 'flyspell-mode)

;; spell checking for latex mode
(add-hook 'latex-mode-hook '(flyspell-mode t))
(add-hook 'LaTeX-mode-hook '(flyspell-mode t))

;; perform a dictionary lookup for word under pointer
(global-set-key (kbd "M-£") 'dictionary-lookup-definition)

;; enable org-download
(require 'org-download)

;; enable evil-collection to fix missing evil mode binds
(evil-collection-init)

;; make default split horizontal
(setq split-width-threshold 1 )

;; Change to biblatex from bibtex
(require 'bibtex)
(bibtex-set-dialect 'biblatex)

;; enable good scroll mode
;; (require 'good-scroll)
;; (good-scroll-mode 1)
;; disabled due to it messing with how jerky

;; set default tab width to 2
(setq-default tab-width 2)

;; Prevent Extraneous Tabs
(setq-default indent-tabs-mode nil)

;; change c style to linux
(setq-default c-default-style "linux")
(setq-default c-basic-offset 2)

;; fixes blinking pdfs in pdf-tools evil mode
;; (evil-set-initial-state 'pdf-view-mode 'emacs)
;; (add-hook 'pdf-view-mode-hook
;;   (lambda ()
;;     (set (make-local-variable 'evil-emacs-state-cursor) (list nil))))
(blink-cursor-mode -1)

;; disable evil mode in the buffer
;; (add-hook 'term-mode-hook 'turn-off-evil-mode)
;; using shell instead

;; Disabling display-line-numbers-mode for pdf-view-mode to prevent an error
(add-hook 'pdf-view-mode-hook
					(lambda ()
						(display-line-numbers-mode -1)))

;; disable highlights being cleaned in I-searches
(setq lazy-highlight-cleanup nil)
;; can clear highlights manually with M-x lazy-highlight-cleanup

;; rebinds M-. to 'xref-find-definitions for tags
(evil-define-key
  '(normal insert visual replace operator motion emacs)
  'global
  (kbd "M-.") 'xref-find-definitions)

;; prevent deletion of the prompt in shell mode
(setq comint-prompt-read-only t)

;; disable evil mode in vterm 
;; (add-hook 'vterm-mode #'turn-off-evil-mode nil t)
(add-hook 'vterm-mode-hook #'turn-off-evil-mode)

;; disable key chord mode in vterm
(defun disable-key-chord-mode ()
  (set (make-local-variable 'input-method-function) nil))
(add-hook 'vterm-mode-hook #'disable-key-chord-mode)

;; disable line numbers in vterm
(add-hook 'vterm-mode-hook
					(lambda ()
						(display-line-numbers-mode -1)))

;; rerun last used compile command with C-c m, can edit the buffer with C-u C-c m
(global-set-key (kbd "C-c m") 'recompile)


;; relative line numbers
(setq display-line-numbers-type 'relative)

;; close compilation window on finish
(defun comp-close-enable ()
(interactive)
(add-hook 'compilation-finish-functions
					(lambda (buf strg)
						(let ((win  (get-buffer-window buf 'visible)))
							(when win (delete-window win)))))
)

(defun comp-close-disable()
(interactive)
(remove-hook 'compilation-finish-functions
					(lambda (buf strg)
						(let ((win  (get-buffer-window buf 'visible)))
							(when win (delete-window win)))))
)

;; highlighting TODO and other words
(use-package hl-todo
:hook (prog-mode . hl-todo-mode)
:config
(setq hl-todo-highlight-punctuation ":"
				hl-todo-keyword-faces
				`(("TODO"       warning bold)
				("FIXME"      error bold)
				("HACK"       font-lock-constant-face bold)
        ("DROPPED"    font-lock-constant-face bold)
				("REVIEW"     font-lock-keyword-face bold)
				("NOTE"       success bold)
				("DEPRECATED" font-lock-doc-face bold))))

;; exclude .stversions from org roam db
;; (setq org-roam-file-exclude-regexp
;;       (concat "^" (expand-file-name org-roam-directory) ".stversions/"))


;; C++ CONFIG ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; enable eglot LSP client for C and C++
(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)
;; enable company text completion framework for C and C++
(add-hook 'c-mode-hook 'company-mode)
(add-hook 'c++-mode-hook 'company-mode)

(add-hook 'c++-mode-hook 'eldoc-box-hover-at-point-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; enable eglot LSP client for python
(add-hook 'python-mode-hook 'eglot-ensure)
;; enable company text completion framework for python
(add-hook 'python-mode-hook 'company-mode)

;; enable flyspell for org mode
(add-hook 'org-mode-hook 'turn-on-flyspell)

(add-hook 'mhtml-mode-hook
					(lambda () (local-set-key (kbd "C-c C-c") 'browse-url-of-file)))
 
;; set python tabs to 2
(add-hook 'python-mode-hook
          (function (lambda ()
                      (setq indent-tabs-mode nil
                            tab-width 2))))

;; window-resize keybinding
;; C-w C-r
(define-key evil-window-map (kbd "r") 'resize-window)

;; adjust resize-window keys
(defvar resize-window-dispatch-alist
  '((?j resize-window--enlarge-down          " Resize - Expand down" t)
    (?k resize-window--enlarge-up            " Resize - Expand up" t)
    (?l resize-window--enlarge-horizontally  " Resize - horizontally" t)
    (?h resize-window--shrink-horizontally   " Resize - shrink horizontally" t)
    (?r resize-window--reset-windows         " Resize - reset window layout" nil)
    (?w resize-window--cycle-window-positive " Resize - cycle window" nil)
    (?W resize-window--cycle-window-negative " Resize - cycle window" nil)
    (?2 split-window-below " Split window horizontally" nil)
    (?3 split-window-right " Slit window vertically" nil)
    (?0 resize-window--delete-window " Delete window" nil)
    (?x resize-window--kill-other-windows " Kill other windows (save state)" nil)
    (?y resize-window--restore-windows " (when state) Restore window configuration" nil)
    (?? resize-window--display-menu          " Resize - display menu" nil))
  "List of actions for `resize-window-dispatch-default.
Main data structure of the dispatcher with the form:
\(char function documentation match-capitals\)")

;; enable ivy
;; (ivy-mode 1)



;; CUSTOM COMMANDS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; open emacs init.el config file in new tab
(defun mac-config ()
""
(interactive)
(find-file (locate-user-emacs-file "init.el")))

;; ;; open org-roam general todo node
;; (defun mac-todo ()
;; "Opens general todo file"
;; (interactive)
;; (org-roam-node-visit (org-roam-node-read "General TODO")))

;; open org-roam dailies today
(defalias 'mac-today 'org-roam-dailies-goto-today)

;; opens yesterday's org-roam daily page
(defalias 'mac-yesterday 'org-roam-dailies-goto-yesterday)

;; opens tomorrow's org-roam daily page
(defalias 'mac-tomorrow 'org-roam-dailies-goto-tomorrow)

;; opens the date's org-roam daily page
(defalias 'mac-date 'org-roam-dailies-goto-date)

;; opens the org-roam capture page for the date
(defalias 'mac-capture 'org-roam-dailies-capture-date)

;; open org-roam jp study
(defun mac-jp ()
"Opens jp study org-roam entry"
(interactive)
(org-roam-node-visit (org-roam-node-read "JP study")))

;; org-roam-node-find alias
(defalias 'mac-find 'org-roam-node-find)

;; Consult ripgrep org-roam search
(defun mac-search ()
"Search org-roam directory using consult-ripgrep. With live-preview."
(interactive)
(let ((consult-grep-command "rg --multiline --null --ignore-case --type org --line-buffered --color=never --mac-columns=500 --no-heading --line-number . -e ARG OPTS"))
  (consult-grep org-roam-directory)))

;; open find-file dialogue with ~/code/ already entered
(defun mac-code ()
  "Opens find-file in the ~/code/ directory"
  (interactive)
  (cd "~/code/")
  (call-interactively 'find-file))

(defun i3()
	(interactive) 
  (find-file "~/.config/i3/config"))
