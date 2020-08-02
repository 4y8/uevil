;;; uevil.el --- A minimal implementation of vi emulation in emacs -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Yul3n
;;
;; Author: Yul3n <http://github/Yul3n>
;; Maintainer: Yul3n <yul3n.falx@protonmail.com>
;; Created: August 01, 2020
;; Modified: August 01, 2020
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/Yul3n/uevil
;; Package-Requires: ((emacs 26.3) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;
;;
;;; Code:

;;; Global variables:
(defvar uevil-normal-map (make-sparse-keymap)
  "The keymap of normal state.")
(defvar uevil-insert-map (make-sparse-keymap)
  "The keymap of insert state.")
(defvar uevil-insert-state-p nil
  "Check if uevil is in insert state.")
(defvar uevil-normal-state-p nil
  "Check if uevil is in normal state.")

;;; Utils:
(defun uevil-suppr ()
  "Delete the character next to the cursor."
  (interactive)
  (read-only-mode -1)
  (delete-char 1)
  (read-only-mode))

(defun uevil-delete-line ()
  "Delete the current line."
  (interactive)
  (read-only-mode -1)
  (kill-whole-line)
  (read-only-mode))

(defun uevil-backward-line ()
  "Go on the line before the current line."
  (interactive)
  (forward-line -1))

(defun uevil-beginning-of-buffer ()
  "Go to the beginning of the buffer."
  (interactive)
  (goto-char (point-min)))

(defun uevil-end-of-buffer ()
  "Go to the end of the buffer."
  (interactive)
  (goto-char (point-max)))

(defun uevil-beginning-of-line ()
  "Go to the beginning of the line."
  (interactive)
  (beginning-of-line))

(defun uevil-end-of-line ()
  "Go to the end the line."
  (interactive)
  (end-of-line))

(defun uevil-line-length ()
  "Return the length of the current line."
  (- (line-end-position) (line-beginning-position)))

;;; States:

;; Normal state
(defun uevil-normal-state ()
  "Set up the uevil normal state AKA \"command state\"."
  (interactive)
  (unless uevil-normal-state-p
    (use-local-map uevil-normal-map)
    (read-only-mode)
    (setq uevil-insert-state-p nil)
    (setq uevil-normal-state-p t)))

;; Insert state
(defun uevil-insert-state ()
  "Set up the uevil insert state."
  (interactive)
  (unless uevil-insert-state-p
    (read-only-mode -1)
    (use-local-map uevil-insert-map)
    (setq uevil-insert-state-p t)
    (setq uevil-normal-state-p nil)))

;;; Keymaps:

;; Normal state
(define-key uevil-normal-map "i" 'uevil-insert-state)

;; Movements
(define-key uevil-normal-map "h"  'backward-char)
(define-key uevil-normal-map "l"  'forward-char)
(define-key uevil-normal-map "j"  'forward-line)
(define-key uevil-normal-map "k"  'uevil-backward-line)
(define-key uevil-normal-map "w"  'forward-word)
(define-key uevil-normal-map "b"  'backward-word)
(define-key uevil-normal-map "gg" 'uevil-beginning-of-buffer)
(define-key uevil-normal-map "G"  'uevil-end-of-buffer)
(define-key uevil-normal-map "0"  'uevil-beginning-of-line)
(define-key uevil-normal-map "$"  'uevil-end-of-line)

;; Deletion
(define-key uevil-normal-map "x"  'uevil-suppr)
(define-key uevil-normal-map "dd" 'uevil-delete-line)

;; Insert state
(define-key uevil-insert-map (kbd "ESC") 'uevil-normal-state)

;;; Main function
(define-minor-mode uevil-mode
  "A major mode to provide vi-like keybindings."
  :lighter uevil
  (uevil-normal-state))

(provide 'uevil-mode)
;;; uevil.el ends here
