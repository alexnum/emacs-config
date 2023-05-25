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
   '(lsp-mode tide rjsx-mode typescript-mode auctex company company-go company-web python-mode vue-mode auto-complete csharp-mode csproj-mode csv-mode js2-mode tern tern-auto-complete ibuffer-sidebar neotree))
 '(safe-local-variable-values '((indent-tabs-mode . true)))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;---------Configuring melpa----------
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)
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
;; Use shopify-cli / theme-check-language-server for Shopify's liquid syntax


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

