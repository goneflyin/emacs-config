;;; ------------------------------------------------
(require 'linum)
(require 'htmlize)

;;; ------------------------------------------------
;;; GNU Server
(load-file "$EMACS_LIB/lib/misc/gnuserv.el")
(load-library "gnuserv")
(gnuserv-start)
(setq gnuserv-frame (selected-frame))

;;; ------------------------------------------------
;;; CUA mode
(if (string-equal "21" (substring (emacs-version) 10 12))
  (progn 
    (load-file "$EMACS_LIB/lib/misc/cua.el")
    (require 'cua)
    (CUA-mode t)))
(if (string-equal "22" (substring (emacs-version) 10 12))
  (progn 
    (cua-mode t)))

;;; ------------------------------------------------
(global-font-lock-mode 1)
(setq c-basic-offset 2)
(setq tab-width 4)
(show-paren-mode t)
(setq-default abbrev-mode t)
(column-number-mode t)
(line-number-mode t)

;;; ------------------------------------------------
(setq max-lisp-eval-depth 1000)
(setq max-specpdl-size 1000)

;;; ------------------------------------------------
;; no TABs allowed
(setq-default indent-tabs-mode nil)
;(highlight-tabs)
;(highlight-trailing-whitespace)

;;; ------------------------------------------------
;; Make all yes-or-no questions as y-or-n
(fset 'yes-or-no-p 'y-or-n-p)

;;; ------------------------------------------------
;; turn off menu and tool bar
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
;(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
;(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;;; ------------------------------------------------
(load "completion")
(initialize-completions)

;;; ------------------------------------------------
;;; inserts current date and time
(defun insert-current-time (arg)
  "Insert current time string at current position"
  (interactive "p")
  (insert (current-time-string)))

;;; ------------------------------------------------
;;; Very useful function allowing to jump to matching parent
(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
	((looking-at "\\s\)") (forward-char 1) (backward-list 1))
	(t (self-insert-command (or arg 1)))))
(global-set-key "%" 'match-paren)

;;; ------------------------------------------------
;;; Indent whole buffer
(defun iwb ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

;;; ------------------------------------------------
;;; IDO
(if (string-equal "21" (substring (emacs-version) 10 12))
  (progn ; only load cua for 21.x
    (load-file "$EMACS_LIB/lib/misc/ido.el")))
(require 'ido)
(ido-mode 'both)
(setq ido-enable-flex-matching t)

;;; ------------------------------------------------
;;; viper and vimpulse modes
;(setq viper-mode t)
;(require 'viper)
;(load-file "$EMACS_LIB/startup/vimpulse.el")
;(require 'vimpulse)

;;; ------------------------------------------------
;;; icicles
;(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/lib/icicles"))
;(load-file "$EMACS_LIB/lib/icicles/icicles.el")
;(icicle-mode t)

;;; ------------------------------------------------
;;; Remote Emacs buffer using Erlang 
;(add-to-list 'load-path (substitute-in-file-name "$EMACS_LIB/lib/shbuf"))
;(require 'shbuf)

;;; ------------------------------------------------
;;; Desktop
;(load-file "$EMACS_LIB/lib/misc/desktop.el")
;(desktop-load-default)
;(setq history-length 250)
;(add-to-list 'desktop-globals-to-save 'file-name-history)
;(desktop-read)
;(setq desktop-enable t)
;(setq desktop-buffers-not-to-save
;        (concat "\\(" "^nn\\.a[0-9]+\\|\\.log\\|(ftp)\\|^tags\\|^TAGS"
;	        "\\|\\.emacs.*\\|\\.diary\\|\\.newsrc-dribble\\|\\.bbdb" 
;	        "\\)$"))
;(add-to-list 'desktop-modes-not-to-save 'dired-mode)
;(add-to-list 'desktop-modes-not-to-save 'Info-mode)
;(add-to-list 'desktop-modes-not-to-save 'info-lookup-mode)
;(add-to-list 'desktop-modes-not-to-save 'fundamental-mode)

;;; ------------------------------------------------
;; turn off anti-aliasing for mac
;(setq mac-allow-anti-aliasing nil)

;;; ------------------------------------------------
;; save a list of open files in ~/.emacs.desktop
;; save the desktop file automatically if it already exists
(setq desktop-save 'if-exists)
(desktop-save-mode 1)

;; save a bunch of variables to the desktop file
;; for lists specify the len of the maximal saved data also
(setq desktop-globals-to-save
      (append '((extended-command-history . 30)
                (file-name-history        . 100)
                (grep-history             . 30)
                (compile-history          . 30)
                (minibuffer-history       . 50)
                (query-replace-history    . 60)
                (read-expression-history  . 60)
                (regexp-history           . 60)
                (regexp-search-ring       . 20)
                (search-ring              . 20)
                (shell-command-history    . 50)
                tags-file-name
                register-alist)))