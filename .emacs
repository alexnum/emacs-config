(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(deeper-blue))
 '(grep-find-ignored-directories
   '("SCCS" "RCS" "CVS" "MCVS" ".src" ".svn" ".git" ".hg" ".bzr" "_MTN" "_darcs" "{arch}" "node_modules" "bower_components" "packages" "DotNetZip" "nHapi"))
 '(inhibit-startup-screen t)
 '(menu-bar-mode nil)
 '(package-selected-packages
   '(gnu-elpa-keyring-update dap-mode helm-lsp lsp-java which-key lsp-ui hydra yasnippet projectile go-guru polymode lsp-mode tide rjsx-mode typescript-mode auctex company company-go company-web python-mode vue-mode auto-complete csharp-mode csproj-mode csv-mode js2-mode tern tern-auto-complete ibuffer-sidebar neotree))
 '(safe-local-variable-values '((indent-tabs-mode . true)))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(setq gud-key-prefix (kbd "C-x C-g"))
;;---------Configuring melpa----------
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)
(package-install 'use-package)
(require 'use-package)
;;-------------------------------------


;;Variable to control to ibuffer-sdebar open requested buffer on most recent window (MRU)
(setq CURRENT_WINDOW nil)



;;---------Configuring neotree sidebar----------
(defun +neotree-toggle ()
  "Toggle both `neotree' and `ibuffer-sidebar'."
  (interactive)
  (if ( and (not (eq major-mode 'neotree-mode)) ( not (eq major-mode 'ibuffer-sidebar-mode)) )
      (setq CURRENT_WINDOW (get-buffer-window))
  )
  (if (eq major-mode 'ibuffer-sidebar-mode)
      (ibuffer-sidebar-toggle-sidebar)
  )
  (neotree-toggle))

(global-set-key (kbd "C-x C-f") '+neotree-toggle)

(defun +neo-open-file (full-path &optional arg)
  (interactive)
  (neo-open-file full-path)
  (neotree-hide)
)

(defun +neo-open-dir (full-path &optional arg)
  (interactive)
  (neotree-dir full-path)
)


(defun +neo-back-dir ()
  (interactive)
  (move-to-window-line 1)
  (neotree-dir (neo-buffer--get-filename-current-line))
)

(add-hook 'neotree-mode-hook
          (lambda ()
	    (local-set-key (kbd "C-x") 'nil)
	    (define-key neotree-mode-map (kbd "DEL") '+neo-back-dir)
	    (define-key neotree-mode-map (kbd "RET")   (neotree-make-executor
							:file-fn '+neo-open-file
							:dir-fn  '+neo-open-dir))
	  )
)
;;----------------------------------------------

;;---------Configuring buffer sidebar----------
(defun +ibffer-toggle ()
  "Toggle both `ibuffer-sidebar' and `neotree'."
  (interactive)
  (if ( and (not (eq major-mode 'neotree-mode)) ( not (eq major-mode 'ibuffer-sidebar-mode)) )
      (setq CURRENT_WINDOW (get-buffer-window))
  )
  (neotree-hide)
  (ibuffer-sidebar-toggle-sidebar)
)

(global-set-key (kbd "C-x C-a") '+ibffer-toggle)

(defun +ibffer-visit ()
  "Toggle both open buffer and closes sidebar"
  (interactive)
  ;;(ibuffer-visit-buffer)
  ;;(previous-window)
  (set-window-buffer CURRENT_WINDOW (buffer-name (ibuffer-current-buffer t)))
  ;;(set-window-buffer (previous-window) (buffer-name (ibuffer-current-buffer t)))
  (ibuffer-sidebar-toggle-sidebar)
)

(add-hook 'ibuffer-sidebar-mode-hook
          (lambda ()
	    (local-set-key (kbd "C-x") 'nil)
	    (local-set-key (kbd "RET") '+ibffer-visit)
	  )
)
;;-----------------------------------------------


;;---------Configuring modes for javascript------
(defun my-js-mode-hook ()
  ;;Usar espaço quando TAB for pressionado
  (setq-default tab-always-indent nil)
  (tern-mode t)
  ;;Não usar espaços
  (setq indent-tabs-mode nil))
(add-hook 'js-mode-hook 'my-js-mode-hook)
;;-----------------------------------------------

;;Never use tabs
(setq-default indent-tabs-mode nil)

;;Show hidden files in neotree
(setq-default neo-show-hidden-files t)

;;-------------Auto Init Mode--------------------
(add-hook 'after-init-hook 'global-company-mode)

;;-------Set Backup dir--------------
(setq backup-directory-alist `(("." . "~/.saves")))

;;configure ts
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (company-mode +1))

(add-hook 'typescript-mode-hook #'setup-tide-mode)


  (with-eval-after-load 'lsp-mode 
  (defvar lsp-language-id-configuration
    '(...
      (vue-mode . "vue")
      ...))

  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection "vue-semantic-server")
                    :activation-fn (lsp-activate-on "vue")
                    :server-id 'vue-semantic-server))
  (add-hook 'vue-mode-hook 'lsp)
  )

;;===================GOLANG===========
;; Install go-mode if not already installed
(unless (package-installed-p 'go-mode)
  (package-install 'go-mode))

;; Set GOPATH and add GOPATH/bin to exec-path
(require 'go-mode)
(add-hook 'go-mode-hook
          (lambda ()
            (setq gofmt-command "gofmt")
            (add-hook 'before-save-hook 'gofmt-before-save)
            (setq tab-width 4)
            (setq indent-tabs-mode nil)))

;; Enable company-mode for autocompletion
(add-hook 'go-mode-hook 'company-mode)

;; Install company-go if not already installed
(unless (package-installed-p 'company-go)
  (package-install 'company-go))

;; Configure company-go
(require 'company-go)
(add-to-list 'company-backends 'company-go)

;; Install flycheck if not already installed
(unless (package-installed-p 'flycheck)
  (package-install 'flycheck))

;; Configure flycheck for go
(require 'flycheck)
(add-hook 'go-mode-hook 'flycheck-mode)

;; Enable go-guru
(add-hook 'go-mode-hook #'go-guru-hl-identifier-mode)
(define-key go-mode-map (kbd "C-c r") 'go-guru-referrers)

;;--Polymode for vue
;; (use-package polymode
;;         :ensure t
;;         :defer t
;;         :hook (vue-mode . lsp-deferred)
;;         :mode ("\\.vue\\'" . vue-mode)
;;         :config


;;         (define-innermode poly-vue-template-innermode
;;           :mode 'html-mode
;;           :head-matcher "<[[:space:]]*template[[:space:]]*[[:space:]]*>"
;;           :tail-matcher "</[[:space:]]*template[[:space:]]*[[:space:]]*>"
;;           :head-mode 'host
;;           :tail-mode 'host)

;;         (define-innermode poly-vue-script-innermode
;;           :mode 'js-mode
;;           :head-matcher "<[[:space:]]*script[[:space:]]*[[:space:]]*>"
;;           :tail-matcher "</[[:space:]]*script[[:space:]]*[[:space:]]*>"
;;           :head-mode 'host
;;           :tail-mode 'host)

;;         (define-innermode poly-vue-typescript-innermode
;;           :mode 'typescript-mode
;;           :head-matcher "<[[:space:]]*script[[:space:]]*lang=[[:space:]]*[\"'][[:space:]]*ts[[:space:]]*[\"'][[:space:]]*>"
;;           :tail-matcher "</[[:space:]]*script[[:space:]]*[[:space:]]*>"
;;           :head-mode 'host
;;           :tail-mode 'host)

;;         (define-innermode poly-vue-typescript-setup-innermode
;;           :mode 'typescript-mode
;;           :head-matcher "<[[:space:]]*script[[:alnum:]\"'[:space:]=]*\\(?:[[:space:]]+\\(?:setup\\|lang=[\"']ts[\"']\\)[[:alnum:]\"'[:space:]=]*\\)*[[:space:]]*>"
;;           :tail-matcher "</[[:space:]]*script[[:space:]]*[[:space:]]*>"
;;           :head-mode 'host
;;           :tail-mode 'host)


;;         (define-innermode poly-vue-javascript-innermode
;;           :mode 'js2-mode
;;           :head-matcher "<[[:space:]]*script[[:space:]]*lang=[[:space:]]*[\"'][[:space:]]*js[[:space:]]*[\"'][[:space:]]*>"
;;           :tail-matcher "</[[:space:]]*script[[:space:]]*[[:space:]]*>"
;;           :head-mode 'host
;;           :tail-mode 'host)

;;         (define-auto-innermode poly-vue-template-tag-lang-innermode
;;           :head-matcher "<[[:space:]]*template[[:space:]]*lang=[[:space:]]*[\"'][[:space:]]*[[:alpha:]]+[[:space:]]*[\"'][[:space:]]*>"
;;           :tail-matcher "</[[:space:]]*template[[:space:]]*[[:space:]]*>"
;;           :mode-matcher (cons  "<[[:space:]]*template[[:space:]]*lang=[[:space:]]*[\"'][[:space:]]*\\([[:alpha:]]+\\)[[:space:]]*[\"'][[:space:]]*>" 1)
;;           :head-mode 'host
;;           :tail-mode 'host)

;;         (define-auto-innermode poly-vue-script-tag-lang-innermode
;;           :head-matcher "<[[:space:]]*script[[:space:]]*lang=[[:space:]]*[\"'][[:space:]]*[[:alpha:]]+[[:space:]]*[\"'][[:space:]]*>"
;;           :tail-matcher "</[[:space:]]*script[[:space:]]*[[:space:]]*>"
;;           :mode-matcher (cons  "<[[:space:]]*script[[:space:]]*lang=[[:space:]]*[\"'][[:space:]]*\\([[:alpha:]]+\\)[[:space:]]*[\"'][[:space:]]*>" 1)
;;           :head-mode 'host
;;           :tail-mode 'host)

;;         (define-auto-innermode poly-vue-style-tag-lang-innermode
;;           :head-matcher "<[[:space:]]*style[[:space:]]*lang=[[:space:]]*[\"'][[:space:]]*[[:alpha:]]+[[:space:]]*[\"'][[:space:]]*>"
;;           :tail-matcher "</[[:space:]]*style[[:space:]]*[[:space:]]*>"
;;           :mode-matcher (cons  "<[[:space:]]*style[[:space:]]*lang=[[:space:]]*[\"'][[:space:]]*\\([[:alpha:]]+\\)[[:space:]]*[\"'][[:space:]]*>" 1)
;;           :head-mode 'host
;;           :tail-mode 'host)

;;         (define-innermode poly-vue-style-innermode
;;           :mode 'css-mode
;;           :head-matcher "<[[:space:]]*style[[:space:]]*[[:space:]]*>"
;;           :tail-matcher "</[[:space:]]*style[[:space:]]*[[:space:]]*>"
;;           :head-mode 'host
;;           :tail-mode 'host)

;;         (define-polymode vue-mode
;;           :hostmode 'poly-sgml-hostmode
;;           :innermodes '(
;;                         poly-vue-typescript-innermode
;;                         poly-vue-typescript-setup-innermode
;;                         poly-vue-javascript-innermode
;;                         poly-vue-template-tag-lang-innermode
;;                         poly-vue-script-tag-lang-innermode
;;                         poly-vue-style-tag-lang-innermode
;;                         poly-vue-template-innermode
;;                         poly-vue-script-innermode
;;                         poly-vue-style-innermode
;;                         )))

;; ===========JAVA=============
(use-package projectile)
(use-package flycheck)
(use-package yasnippet :config (yas-global-mode))
(use-package lsp-mode :hook ((lsp-mode . lsp-enable-which-key-integration))
  :config (setq lsp-completion-enable-additional-text-edit nil))
(use-package hydra)
(use-package company)
(use-package lsp-ui)
(use-package which-key :config (which-key-mode))
(use-package lsp-java :config (add-hook 'java-mode-hook 'lsp))
(use-package dap-mode :after lsp-mode :config (dap-auto-configure-mode))
(use-package dap-java :ensure nil)
(use-package helm-lsp)
(use-package helm
  :config (helm-mode))
(use-package lsp-treemacs)

(with-eval-after-load 'lsp-mode
  (define-key lsp-mode-map (kbd "M-RET") 'lsp-execute-code-action))

(setq org-agenda-files '("~/orgs"))
(add-hook 'org-mode-hook
  (lambda ()
   (local-set-key (kbd "C-c a") 'org-agenda)))
