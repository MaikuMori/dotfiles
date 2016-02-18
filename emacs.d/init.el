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

(package-initialize)

;; Cask manages our package dependencies.
(require 'cask "~/.cask/cask.el")
(cask-initialize)

;; Pallet allows us to use Cask in tandem with `package.el`.
(require 'pallet)
(pallet-mode t)

;; Load up Org-babel.
(require 'ob-tangle)

;; Load our main configuration file.
(org-babel-load-file (expand-file-name "maiku.org" user-emacs-directory))

;;; init.el ends here
