;; use MELPA
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))

;; yasnippet parentheses auto complete
(require 'yasnippet)
(yas-global-mode 1)

;; include helm
;;(add-to-list 'load-path "~/.emacs.d/emacs-helm/")
(require 'helm-config)
(require 'helm-grep)

;; include ecb
(add-to-list 'load-path "~/.emacs.d/ecb/")
(require 'ecb)
(require 'ecb-autoloads)

;; include haskell mode
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)

;; include autopair
(require 'autopair)

;; include textmate
(add-to-list 'load-path "~/.emacs.d/emacs-textmate/")
(require 'textmate)
(tm/initialize)

;; include mu mail client
(add-to-list 'load-path "~/.emacs.d/mu/mu4e/")
(require 'mu4e)

;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebihnd tab to do persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-quick-update                     t ; do not display invisible candidates
      helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-buffers-fuzzy-matching           t ; fuzzy matching buffer names when non--nil
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t)

(helm-mode 1)

;; Change window moving pattern
(windmove-default-keybindings)

;; ecb configs 
(setq ecb-show-sources-in-directories-buffer 'always)
(setq ecb-compile-window-height 12)

(ecb-layout-define "my-own-layout" top nil   
		   ;; 1. Defining the current window/buffer as ECB-methods buffer
		   (ecb-set-directories-buffer)
		   ;; 2. Splitting the ECB-tree-windows-column in two windows
		   (ecb-split-hor 0.4 t)
		   ;; 3. Go to the second window
		   (other-window 1)
		   ;; 4. Defining the current window/buffer as ECB-history buffer
		   (ecb-set-sources-buffer)
		   (ecb-split-hor 0.5 t)
		   (select-window(next-window))
		   (ecb-set-history-buffer)
		   ;; 7. Make the ECB-edit-window current (see Postcondition above)
		   (select-window (next-window)))

(setq ecb-layout-name "my-own-layout")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ecb-layout-window-sizes (quote (("my-own-layout" (ecb-directories-buffer-name 0.39915966386554624 . 0.17857142857142858) (ecb-sources-buffer-name 0.29831932773109243 . 0.17857142857142858) (ecb-history-buffer-name 0.3025210084033613 . 0.17857142857142858)))))
 '(ecb-options-version "2.40"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;;; replacement for built-in ecb-deactive, ecb-hide-ecb-windows and
;;; ecb-show-ecb-windows functions
;;; since they hide/deactive ecb but not restore the old windows for me
(defun tmtxt/ecb-deactivate ()
  "deactive ecb and then split emacs into 2 windows that contain 2 most recent buffers"
  (interactive)
  (ecb-deactivate)
  (split-window-right)
  (switch-to-next-buffer)
  int ((other-window 1)))
(defun tmtxt/ecb-hide-ecb-windows ()
  "hide ecb and then split emacs into 2 windows that contain 2 most recent buffers"
  (interactive)
  (ecb-hide-ecb-windows)
  (split-window-right)
  (switch-to-next-buffer)
  (other-window 1))
(defun tmtxt/ecb-show-ecb-windows ()
  "show ecb windows and then delete all other windows except the current one"
  (interactive)
  (ecb-show-ecb-windows)
  (delete-other-windows))

;;; activate and deactivate ecb
(global-set-key (kbd "C-x ;") 'ecb-activate)
(global-set-key (kbd "C-x '") 'tmtxt/ecb-deactivate)

;;; show/hide ecb window
(global-set-key (kbd "C-x [") 'tmtxt/ecb-show-ecb-windows)
(global-set-key (kbd "C-x ]") 'tmtxt/ecb-hide-ecb-windows)

;;; quick navigation between ecb windows
(global-set-key (kbd "C-c 0") 'ecb-goto-window-edit1)
(global-set-key (kbd "C-c 9") 'ecb-goto-window-edit2)
(global-set-key (kbd "C-c 1") 'ecb-goto-window-directories)
(global-set-key (kbd "C-c 2") 'ecb-goto-window-sources)
(global-set-key (kbd "C-c 3") 'ecb-goto-window-history)
(global-set-key (kbd "C-c 4") 'ecb-goto-window-compilation)

;; =============
;; irony-mode
;; =============
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)

;; =============
;; company mode
;; =============
(add-hook 'c++-mode-hook 'company-mode)
(add-hook 'c-mode-hook 'company-mode)
;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's function
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))
;; (optional) adds CC special commands to `company-begin-commands' in order to
;; trigger completion at interesting places, such as after scope operator
;;     std::|
(add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)

;; =============
;; flycheck-mode
;; =============
(add-hook 'c++-mode-hook 'flycheck-mode)
(add-hook 'c-mode-hook 'flycheck-mode)
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

(eval-after-load 'flycheck
  '(progn
     (set-face-attribute 'flycheck-warning nil
			 :foreground "black"
			 :background "yellow")))
(eval-after-load 'flycheck
  '(progn
     (set-face-attribute 'flycheck-error nil
			 :foreground "red"
			 :background "yellow")))

;; =============
;; eldoc-mode
;; =============
(add-hook 'irony-mode-hook 'irony-eldoc)

;; ==========================================
;; (optional) bind TAB for indent-or-complete
;; ==========================================
(defun irony--check-expansion ()
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
	(backward-char 1)
	(if (looking-at "->") t nil)))))
(defun irony--indent-or-complete ()
  "Indent or Complete"
  (interactive)
  (cond ((and (not (use-region-p))
	      (irony--check-expansion))
	 (message "complete")
	 (company-complete-common))
	(t
	 (message "indent")
	 (call-interactively 'c-indent-line-or-region))))
(defun irony-mode-keys ()
  "Modify keymaps used by `irony-mode'."
  (local-set-key (kbd "TAB") 'irony--indent-or-complete)
  (local-set-key [tab] 'irony--indent-or-complete))
(add-hook 'c-mode-common-hook 'irony-mode-keys)

;; ==========================================
;; (optional) bind M-o for ff-find-other-file
;; ==========================================
(defvar my-cpp-other-file-alist
  '(("\\.cpp\\'" (".h" ".hpp" ".ipp"))
    ("\\.ipp\\'" (".hpp" ".cpp"))
    ("\\.hpp\\'" (".ipp" ".cpp"))
    ("\\.cxx\\'" (".hxx" ".ixx"))
    ("\\.ixx\\'" (".cxx" ".hxx"))
    ("\\.hxx\\'" (".ixx" ".cxx"))
    ("\\.c\\'" (".h"))
    ("\\.h\\'" (".cpp" "c"))))
(setq-default ff-other-file-alist 'my-cpp-other-file-alist)
(add-hook 'c-mode-common-hook (lambda ()
				(define-key c-mode-base-map [(meta o)] 'ff-get-other-file)))

;; Key definitions
(global-set-key (kbd "M-r") 'query-replace)
(global-set-key (kbd "C-c e") 'eshell)

;; default
;; Mu email client
(setq mu4e-maildir "~/Mail/personal")
(setq mu4e-drafts-folder "/[Gmail].Drafts")
(setq mu4e-sent-folder   "/[Gmail].Sent Mail")
(setq mu4e-trash-folder  "/[Gmail].Trash")

;; don't save message to Sent Messages, Gmail/IMAP takes care of this
(setq mu4e-sent-messages-behavior 'delete)

;; (See the documentation for `mu4e-sent-messages-behavior' if you have
;; additional non-Gmail addresses and want assign them different
;; behavior.)

;; setup some handy shortcuts
;; you can quickly switch to your Inbox -- press ``ji''
;; then, when you want archive some messages, move them to
;; the 'All Mail' folder by pressing ``ma''.

(setq mu4e-maildir-shortcuts
      '( ("/INBOX"               . ?i)
	 ("/[Gmail].Sent Mail"   . ?s)
	 ("/[Gmail].Trash"       . ?t)
	 ("/[Gmail].All Mail"    . ?a)))

;; allow for updating mail using 'U' in the main view:
(setq mu4e-get-mail-command "offlineimap")

;; something about ourselves
(setq
 user-mail-address "ryan.houlihan90@gmail.com"
 user-full-name  "Foo X. Bar"
 mu4e-compose-signature
 (concat
  "Ryan Houlihan\n"
  "Stanford University\n"
  "Mechanical Engineering\n")
 )
;; sending mail -- replace USERNAME with your gmail username
;; also, make sure the gnutls command line utils are installed
;; package 'gnutls-bin' in Debian/Ubuntu

(require 'smtpmail)
(setq message-send-mail-function 'smtpmail-send-it
      starttls-use-gnutls t
      smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
      smtpmail-auth-credentials
      '(("smtp.gmail.com" 587 "ryan.houlihan90@gmail.com" nil))
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587)

;; alternatively, for emacs-24 you can use:
;;(setq message-send-mail-function 'smtpmail-send-it
;;     smtpmail-stream-type 'starttls
;;     smtpmail-default-smtp-server "smtp.gmail.com"
;;     smtpmail-smtp-server "smtp.gmail.com"
;;     smtpmail-smtp-service 587)

;; don't keep message buffers around
(setq message-kill-buffer-on-exit t)
