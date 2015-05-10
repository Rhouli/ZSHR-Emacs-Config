;; use MELPA
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))

;; include async
(add-to-list 'load-path "~/.emacs.d/emacs-async/")
(when (require 'dired-aux)
  (require 'dired-async))

;; include helm
(add-to-list 'load-path "~/.emacs.d/emacs-helm/")
(require 'helm-config)
(require 'helm-grep)

;; includ ecb
(require 'ecb)
(require 'ecb-autoloads)

;; include haskell mode
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)

(add-to-list 'load-path "~/.emacs.d/emacs-clang-complete-async/")
(require 'auto-complete-clang-async)

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

;; clang async
(defun ac-cc-mode-setup ()
  (setq ac-clang-complete-executable "~/.emacs.d/clang-complete")
  (setq ac-sources '(ac-source-clang-async))
  (ac-clang-launch-completion-process)
)
(defun ac-common-setup ()
 ())

(defun my-ac-config ()
  (add-hook 'c-mode-common-hook 'ac-cc-mode-setup)
  (add-hook 'auto-complete-mode-hook 'ac-common-setup)
  (global-auto-complete-mode t))

(my-ac-config)
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ecb-options-version "2.40")
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; ecb configs 
(setq ecb-layout-name "left3")
(setq ecb-show-sources-in-directories-buffer 'always)
(setq ecb-compile-window-height 12)

;;; replacement for built-in ecb-deactive, ecb-hide-ecb-windows and
;;; ecb-show-ecb-windows functions
;;; since they hide/deactive ecb but not restore the old windows for me
(defun tmtxt/ecb-deactivate ()
  "deactive ecb and then split emacs into 2 windows that contain 2 most recent buffers"
  (interactive)
  (ecb-deactivate)
  (split-window-right)
  (switch-to-next-buffer)
  (other-window 1))
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
(global-set-key (kbd "C-c 3") 'ecb-goto-window-methods)
(global-set-key (kbd "C-c 4") 'ecb-goto-window-compilation)
