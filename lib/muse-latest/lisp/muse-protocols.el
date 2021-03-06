;;; muse-protocols.el --- URL protocols that Muse recognizes

;; Copyright (C) 2005, 2006, 2007 Free Software Foundation, Inc.

;; Author: Brad Collins (brad AT chenla DOT org)

;; This file is part of Emacs Muse.  It is not part of GNU Emacs.

;; Emacs Muse is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your
;; option) any later version.

;; Emacs Muse is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Emacs Muse; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Here's an example for adding a protocol for the site yubnub, a Web
;; Command line service.
;;
;; (add-to-list 'muse-url-protocols '("yubnub://" muse-browse-url-yubnub
;;                                                muse-resolve-url-yubnub))
;;
;; (defun muse-resolve-url-yubnub (url)
;;   "Resolve a yubnub URL."
;;   ;; Remove the yubnub://
;;   (when (string-match "\\`yubnub://\\(.+\\)" url)
;;     (match-string 1)))
;;
;; (defun muse-browse-url-yubnub (url)
;;   "If this is a yubnub URL-command, jump to it."
;;   (setq url (muse-resolve-url-yubnub url))
;;   (browse-url (concat "http://yubnub.org/parser/parse?command="
;;                       url)))

;;; Contributors:

;; Phillip Lord (Phillip.Lord AT newcastle DOT ac DOT uk) provided a
;; handler for DOI URLs.

;; Stefan Schlee fixed a bug with handling of colons at the end of
;; URLs.

;; Valery V. Vorotyntsev contribued the woman:// protocol handler and
;; simplified `muse-browse-url-man'.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Muse URL Protocols
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'info)
(require 'muse-regexps)

(defvar muse-url-regexp nil
  "A regexp used to match URLs within a Muse page.
This is autogenerated from `muse-url-protocols'.")

(defun muse-update-url-regexp (sym value)
  (setq muse-url-regexp
        (concat "\\<\\(" (mapconcat 'car value "\\|") "\\)"
                "[^][" muse-regexp-blank "\"'()<>^`{}\n]*"
                "[^][" muse-regexp-blank "\"'()<>^`{}.,;:\n]+"))
  (set sym value))

(defcustom muse-url-protocols
  '(("[uU][rR][lL]:" muse-browse-url-url identity)
    ("info://" muse-browse-url-info nil)
    ("man://" muse-browse-url-man nil)
    ("woman://" muse-browse-url-woman nil)
    ("google://" muse-browse-url-google muse-resolve-url-google)
    ("http:/?/?" browse-url identity)
    ("https:/?/?" browse-url identity)
    ("ftp:/?/?" browse-url identity)
    ("gopher://" browse-url identity)
    ("telnet://" browse-url identity)
    ("wais://" browse-url identity)
    ("file://?" browse-url identity)
    ("dict:" muse-browse-url-dict muse-resolve-url-dict)
    ("doi:" muse-browse-url-doi muse-resolve-url-doi)
    ("news:" browse-url identity)
    ("snews:" browse-url identity)
    ("mailto:" browse-url identity))
  "A list of (PROTOCOL BROWSE-FUN RESOLVE-FUN) used to match URL protocols.
PROTOCOL describes the first part of the URL, including the
\"://\" part.  This may be a regexp.

BROWSE-FUN should accept URL as an argument and open the URL in
the current window.

RESOLVE-FUN should accept URL as an argument and return the final
URL, or nil if no URL should be included."
  :type '(repeat (list :tag "Protocol"
                       (string :tag "Regexp")
                       (function :tag "Browse")
                       (choice (function :tag "Resolve")
                               (const :tag "Don't resolve" nil))))
  :set 'muse-update-url-regexp
  :group 'muse)

(add-hook 'muse-update-values-hook
          (lambda ()
            (muse-update-url-regexp 'muse-url-protocols muse-url-protocols)))

(defcustom muse-wikipedia-country "en"
  "Indicate the 2-digit country code that we use for Wikipedia
queries."
  :type 'string
  :options '("de" "en" "es" "fr" "it" "pl" "pt" "ja" "nl" "sv")
  :group 'muse)

(defun muse-protocol-find (proto list)
  "Return the first element of LIST whose car matches the regexp PROTO."
  (catch 'found
    (dolist (item list)
      (when (string-match (concat "\\`" (car item)) proto)
        (throw 'found item)))))

;;;###autoload
(defun muse-browse-url (url &optional other-window)
  "Handle URL with the function specified in `muse-url-protocols'.
If OTHER-WINDOW is non-nil, open in a different window."
  (interactive (list (read-string "URL: ")
                     current-prefix-arg))
  ;; Strip text properties
  (when (fboundp 'set-text-properties)
    (set-text-properties 0 (length url) nil url))
  (when other-window
    (switch-to-buffer-other-window (current-buffer)))
  (when (string-match muse-url-regexp url)
    (let* ((proto (match-string 1 url))
           (entry (muse-protocol-find proto muse-url-protocols)))
      (when entry
        (funcall (cadr entry) url)))))

(defun muse-resolve-url (url &rest ignored)
  "Resolve URL with the function specified in `muse-url-protocols'."
  (when (string-match muse-url-regexp url)
    (let* ((proto (match-string 1 url))
           (entry (muse-protocol-find proto muse-url-protocols)))
      (when entry
        (let ((func (car (cddr entry))))
          (if func
              (setq url (funcall func url))
            (setq url nil))))))
  url)

(defun muse-protocol-add (protocol browse-function resolve-function)
  "Add PROTOCOL to `muse-url-protocols'.  PROTOCOL may be a regexp.

BROWSE-FUNCTION should be a function that visits a URL in the
current buffer.

RESOLVE-FUNCTION should be a function that transforms a URL for
publishing or returns nil if not linked."
  (add-to-list 'muse-url-protocols
               (list protocol browse-function resolve-function))
  (muse-update-url-regexp 'muse-url-protocols
                          muse-url-protocols))

(defun muse-browse-url-url (url)
  "Call `muse-protocol-browse-url' to browse URL.
This is used when we are given something like
\"URL:http://example.org/\".

If you're looking for a good example for how to make a custom URL
handler, look at `muse-browse-url-dict' instead."
  (when (string-match "\\`[uU][rR][lL]:\\(.+\\)" url)
    (muse-browse-url (match-string 1 url))))

(defun muse-resolve-url-dict (url)
  "Return the Wikipedia link corresponding with the given URL."
  (when (string-match "\\`dict:\\(.+\\)" url)
    (concat "http://" muse-wikipedia-country ".wikipedia.org/"
            "wiki/Special:Search?search=" (match-string 1 url))))

(defun muse-browse-url-dict (url)
  "If this is a Wikipedia URL, browse it."
  (let ((dict-url (muse-resolve-url-dict url)))
    (when dict-url
      (browse-url dict-url))))

(defun muse-resolve-url-doi (url)
  "Return the URL through DOI proxy server."
  (when (string-match "\\`doi:\\(.+\\)" url)
    (concat "http://dx.doi.org/"
            (match-string 1 url))))

(defun muse-browse-url-doi (url)
  "If this is a DOI URL, browse it.

DOI's (digitial object identifiers) are a standard identifier
used in the publishing industry."
  (let ((doi-url (muse-resolve-url-doi url)))
    (when doi-url
      (browse-url doi-url))))

(defun muse-resolve-url-google (url)
  "Return the correct Google search string."
  (when (string-match "\\`google:/?/?\\(.+\\)" url)
    (concat "http://www.google.com/search?q="
            (match-string 1 url))))

(defun muse-browse-url-google (url)
  "If this is a Google URL, jump to it."
  (let ((google-url (muse-resolve-url-google url)))
    (when google-url
      (browse-url google-url))))

(defun muse-browse-url-info (url)
  "If this in an Info URL, jump to it."
  (require 'info)
  (cond
   ((string-match "\\`info://\\([^#\n]+\\)#\\(.+\\)" url)
    (Info-find-node (match-string 1 url)
                    (match-string 2 url)))
   ((string-match "\\`info://\\([^#\n]+\\)" url)
    (Info-find-node (match-string 1 url)
                    "Top"))
   ((string-match "\\`info://(\\([^)\n]+\\))\\(.+\\)" url)
    (Info-find-node (match-string 1 url) (match-string 2 url)))
   ((string-match "\\`info://\\(.+\\)" url)
    (Info-find-node (match-string 1 url) "Top"))))

(defun muse-browse-url-man (url)
  "If this in a manpage URL, jump to it."
  (when (string-match "\\`man://\\([^(]+\\(([^)]+)\\)?\\)" url)
    (man (match-string 1 url))))

(defun muse-browse-url-woman (url)
  "If this is a WoMan URL, jump to it."
  (when (string-match "\\`woman://\\(.+\\)" url)
    (woman (match-string 1 url))))

(provide 'muse-protocols)

;;; muse-protocols.el ends here
