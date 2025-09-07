(defvar emacs/default-font-size 150)

(setq inhibit-starting-message t)

(scroll-bar-mode 1) ;; enable scroll bar
(menu-bar-mode 1) ;; enable menu bar

(load-theme 'modus-operandi-tritanopia t)

(global-set-key (kbd "M-3") (lambda () (interactive) (insert "#")))

;;  (set-face-attribute 'default nil :font "Fira Code Retina" :height emacs/default-font-size)

(set-face-attribute 'default nil :height emacs/default-font-size)

  ;; Set the fixed pitch face
;;  (set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 150)

  ;; Set the variable pitch face
;;  (set-face-attribute 'variable-pitch nil :font "Cantarell" :height 200 :weight 'regular)

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)	
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(setq fast-but-imprecise-scrolling t)
(setq redisplay-skip-fontification-on-input t)
(setq inhibit-compacting-font-caches t)

(setq gc-cons-threshold 100000000) ;; 100MB
(setq read-process-output-max (* 1024 1024)) ;; 1MB (helps LSP too)

(setq org-fontify-whole-heading-line nil) ;; only color the text, not the full line
(setq org-fontify-quote-and-verse-blocks nil) ;; skip extra styling on quotes

(defun efs/org-font-setup ()
    ;; Replace list hyphen with dot
    (font-lock-add-keywords 'org-mode
                            '(("^ *\\([-]\\) "
                               (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

    ;; Set faces for heading levels
;;    (dolist (face '((org-level-1 . 1.2)
;;                    (org-level-2 . 1.1)
;;                    (org-level-3 . 1.05)
;;                    (org-level-4 . 1.0)
;;                    (org-level-5 . 1.1)
;;                    (org-level-6 . 1.1)
;;                    (org-level-7 . 1.1)
;;                    (org-level-8 . 1.1)))
;;      (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

     ;; Ensure that anything that should be fixed-pitch in Org files appears that way
    (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
    (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
    (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
    (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))


  (use-package org
    :hook (org-mode . efs/org-mode-setup)
    :config
    (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files			
  	'("~/Orgfiles/Tasks/Tasks.org"
  	  "~/Orgfiles/Tasks/Home.org"
  	  "~/Orgfiles/Tasks/Uni.org"
  	  "~/Orgfiles/Journal/Journal.org"))

   (require 'org-habit)
    (add-to-list 'org-modules 'org-habit)
    (setq org-habit-graph-column 60)

    (setq org-todo-keywords
  	'((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")))

    (setq org-refile-targets
      '(("~/Tasks/Tasks.org" :maxlevel . 2)
        ("~/Tasks/Home.org" :maxlevel . 2)
        ("~/Tasks/Uni.org" :maxlevel . 2)
        ("~/Tasks/Journal.org" :maxlevel . 2)))

    ;; Save Org buffers after refiling!
    (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
      '((:startgroup)
         ; Put mutually exclusive tags here
         (:endgroup)
         ("assignment" . ?a)
         ("research" . ?r)
         ("assessment" . ?A)
         ("quiz" . ?q)
         ("lab" . ?l)
         ("habit" . ?h)))

  (setq org-capture-templates
      `(("t" "Tasks / Projects")
        ("tt" "Task" entry (file+olp "~/Orgfiles/Tasks/Tasks.org" "Quick-capture")
             "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

        ("j" "Journal Entries")
        ("jj" "Journal" entry
             (file+olp+datetree "~/Orgfiles/Journal/Journal.org")
             "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
             ;; ,(dw/read-file-as-string "~/Orgfiles/Journal/Journal.org")
             :clock-in :clock-resume
             :empty-lines 1)

        ("m" "Metrics Capture")
        ("mh" "Health" table-line (file+headline "~/Orgfiles/Health/Health.org" "Health")
         "| %U | %^{Type}  | %^{Food}  | %^{Calories} | %^{Notes}  |" :kill-buffer t)))

  (efs/org-font-setup))

    
  (use-package org-bullets
    :after org
    :hook (org-mode . org-bullets-mode)
    :custom
    (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;;  (use-package all-the-icons)

;;  (use-package doom-modeline
;;  :init (doom-modeline-mode 1)
;;  :custom ((doom-modeline-height 15)))

(use-package evil
    :init
    (setq evil-want-integration t)
    (setq evil-want-keybinding nil)
    (setq evil-want-C-u-scroll t)
    (setq evil-want-C-i-jump nil)
    :config
    (evil-mode 1)
    (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
    (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

    (evil-set-initial-state 'messages-buffer-mode 'normal)
    (evil-set-initial-state 'dashboard-mode 'normal))

  (use-package evil-collection
    :after evil
    :config
    (evil-collection-init))

(setq org-src-tab-acts-natively t) ;; (Makes the src code blocks act like a normal c file)

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package cc-mode
  :ensure nil
  :mode ("\\.c\\'" . c-mode)
  :hook (c-mode . lsp-deferred)
  :config
  ;; optional: 2-space indentation
  (setq c-basic-offset 2))

(use-package company
  :after lsp-mode
  :hook ((lsp-mode . company-mode)
         (c-mode . company-mode)) ;; add company-mode to c-mode explicitly
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection)
         :map lsp-mode-map
              ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package smartparens
  :hook ((prog-mode . smartparens-mode))
  :config
  (require 'smartparens-config))

(use-package yasnippet
  :hook ((c-mode . yas-minor-mode)))

(require 'ob-C)  ;; loads ob-C.el.gz transparently

(org-babel-do-load-languages
 'org-babel-load-languages
 '((C . t)))

(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("code" . "src C"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list `org-structure-template-alist `("sh" . "src shell"))

;; Automatically tangle our Emacs.org config file when we save it
    (defun efs/org-babel-tangle-config ()
      (when (string-equal (buffer-file-name)
                          (expand-file-name "~/.emacs.d/Emacs.org"))

        ;; Dynamic scoping to the rescue
        (let ((org-confirm-babel-evaluate nil))
          (org-babel-tangle))))

    (add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(defun my-c-compile ()
  "Compile current C file."
  (interactive)
  (let ((file (buffer-file-name)))
    (compile (format "gcc -Wall -O2 -o %s %s"
                     (file-name-sans-extension file)
                     file))))
                     
(add-hook 'c-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-c") 'my-c-compile)))

(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))

(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 5000))

;; NOTE: If you want to move everything out of the ~/.emacs.d folder
;; reliably, set `user-emacs-directory` before loading no-littering!
;(setq user-emacs-directory "~/.cache/emacs")

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(use-package projectile
:diminish projectile-mode
:config (projectile-mode)
:custom ((projectile-completion-system 'ivy))
:bind-keymap
("C-c p" . projectile-command-map)
:init
;; NOTE: Set this to the folder where you keep your Git repos!
(when (file-directory-p "~/Projects/Emacs")
  (setq projectile-project-search-path '("~/Projects/Emacs")))
(setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
:config (counsel-projectile-mode))

(use-package magit
    :ensure t
    :bind (("C-x g" . magit-status)))

  (use-package forge
:after magit)

;; Enable LaTeX PDF export in Org
(require 'ox-latex)

;; Use xelatex for better font support (optional)
(setq org-latex-pdf-process
      '("xelatex -interaction=nonstopmode -output-directory=%o %f"
        "xelatex -interaction=nonstopmode -output-directory=%o %f"))

;; Show each buffer as a tab (like Chrome)
(global-tab-line-mode 1)

;; Place tabs at the bottom (default is top)
(setq tab-line-position 'bottom)

;; Keybindings to move between tabs
(global-set-key (kbd "s-<right>") #'tab-line-switch-to-next-tab)
(global-set-key (kbd "s-<left>")  #'tab-line-switch-to-prev-tab)

(defun my/applications-directory ()
  "Return list of .app bundles in /Applications."
  (directory-files "/Applications" t "\\.app\\'"))

(defun my/launch-app (app-path)
  "Launch macOS application at APP-PATH."
  (start-process "app-launcher" nil "open" "-a" app-path))

(dolist (app (my/applications-directory))
  (let* ((name (file-name-base app))
         (fn   (intern (concat "app/open-" (replace-regexp-in-string " " "-" (downcase name))))))
    (fset fn `(lambda () (interactive) (my/launch-app ,app)))
    (put fn 'function-documentation (concat "Launch " name))
    (defalias fn (symbol-function fn))))
