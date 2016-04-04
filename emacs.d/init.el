;;; init.el --- Bootstrap Emacs configuration

;;; Commentary:

;; This file loads Org-mode and then loads the rest of our Emacs
;; initialization from Emacs Lisp embedded in literate Org-mode files.

;;; Code:

;; Turn off mouse interface early in startup to avoid momentary display.
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

(setq inhibit-startup-message t)
(setq initial-scratch-message "")

;; Keep custom variable garbage out of my git.
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives
             '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)

;; Bootstrap `use-package'.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Load up Org-babel.
(require 'ob-tangle)

;; Load our main configuration file.
(org-babel-load-file (expand-file-name "maiku.org" user-emacs-directory))

;;; init.el ends here
