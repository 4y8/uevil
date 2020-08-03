;;; uevil.el --- a minimal implementation of vi emulation in emacs -*- lexical-binding: t; -*-
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
(defvar uevil-visual-map (make-sparse-keymap)
  "The keymap of visual state.")
(defvar uevil-normal-state-p nil
  "Check if uevil is in normal state.")
(defvar uevil-insert-state-p nil
  "Check if uevil is in insert state.")
(defvar uevil-visual-state-p nil
  "Check if uevil is in visual state.")

;;; Ex:
(defun uevil-ex (in)
  "Run uevil ex prompt on the input as IN."
  (interactive "s: ")
  (cond
   ((string= in "w") (save-buffer))
   ((string= in "q") (kill-buffer))
   ((string= in "wq")
    (save-buffer)
    (kill-buffer))
   (t (message "Unknown command: '%s'" in))))

;;; States:

;; Normal state
(defun uevil-normal-state ()
  "Set up the uevil normal state AKA \"command state\"."
  (interactive)
  (unless uevil-normal-state-p
    (use-local-map uevil-normal-map)
    (read-only-mode)
    (setq uevil-insert-state-p nil)
    (setq uevil-visual-state-p nil)
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

;; Visual state
(defun uevil-visual-state ()
  "Set up the uevil visual state."
  (interactive)
  (unless uevil-visual-state-p
    (set-mark (point))
    (use-local-map uevil-visual-map)
    (setq uevil-visual-state-p t)
    (setq uevil-normal-state-p nil)))

;;; Utils:

;; State changes
(defun uevil-append ()
  "Enter insert state after the current cursor."
  (interactive)
  (forward-char)
  (uevil-insert-state))

(defun uevil-insert-beginning-line ()
  "Enter insert state at the beginning of the line."
  (interactive)
  (beginning-of-line)
  (uevil-insert-state))

(defun uevil-insert-end-line ()
  "Enter in insert state at the end of the line."
  (interactive)
  (end-of-line)
  (uevil-insert-state))

(defun uevil-insert-new-line ()
  "Enter insert state on a new line."
  (interactive)
  (end-of-line)
  (read-only-mode -1)
  (insert "
")
  (read-only-mode)
  (uevil-insert-state))

;; Text deletion
(defun uevil-suppr ()
  "Delete the character next to the cursor."
  (interactive)
  (read-only-mode -1)
  (delete-char 1)
  (read-only-mode))

(defun uevil-suppr-before ()
  "Delete the character next to the cursor."
  (interactive)
  (read-only-mode -1)
  (delete-char -1)
  (read-only-mode))

(defun uevil-delete-line ()
  "Delete the current line."
  (interactive)
  (read-only-mode -1)
  (kill-whole-line)
  (read-only-mode))

;; Copy and paste
(defun uevil-yank-line ()
  "Copy the line to the kill ring."
  (interactive)
  (copy-region-as-kill (line-beginning-position) (line-end-position)))

(defun uevil-paste ()
  "Paste from the kill ring to the buffer."
  (interactive)
  (read-only-mode -1)
  (yank)
  (read-only-mode))

(defun uevil-undo ()
  "Undo."
  (interactive)
  (undo))

;; Movements
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

(defun uevil-forward-line ()
  "Go to the next line."
  (interactive)
  (let ((pos (- (point) (line-beginning-position))))
    (forward-line 1)
    (forward-char (min pos (uevil-line-length)))))

(defun uevil-backward-line ()
  "Go to the previous line."
  (interactive)
  (let ((pos (- (point) (line-beginning-position))))
    (forward-line -1)
    (forward-char (min pos (uevil-line-length)))))

(defun uevil-forward-char ()
  "Go to the next character."
  (interactive)
  (forward-char))

(defun uevil-backward-char ()
  "Go to the previous character."
  (interactive)
  (backward-char))

;;; Keymaps:

;; Normal state
;  Switch states
(define-key uevil-normal-map "i" 'uevil-insert-state)
(define-key uevil-normal-map "v" 'uevil-visual-state)
(define-key uevil-normal-map ":" 'uevil-ex)
(define-key uevil-normal-map "a" 'uevil-append)
(define-key uevil-normal-map "I" 'uevil-insert-beginning-line)
(define-key uevil-normal-map "A" 'uevil-insert-end-line)
(define-key uevil-normal-map "o" 'uevil-insert-new-line)

;; Copy and paste
(define-key uevil-normal-map "p" 'uevil-paste)
(define-key uevil-normal-map "Y" 'uevil-yank-line)
(define-key uevil-normal-map "u" 'uevil-undo)

;; Movements
(define-key uevil-normal-map "h"  'backward-char)
(define-key uevil-normal-map "l"  'forward-char)
(define-key uevil-normal-map "j"  'uevil-forward-line)
(define-key uevil-normal-map "k"  'uevil-backward-line)
(define-key uevil-normal-map "w"  'forward-word)
(define-key uevil-normal-map "b"  'backward-word)
(define-key uevil-normal-map "gg" 'uevil-beginning-of-buffer)
(define-key uevil-normal-map "G"  'uevil-end-of-buffer)
(define-key uevil-normal-map "0"  'uevil-beginning-of-line)
(define-key uevil-normal-map "$"  'uevil-end-of-line)
(define-key uevil-normal-map (kbd "DEL")     'backward-char)
(define-key uevil-normal-map (kbd "<right>") 'forward-char)
(define-key uevil-normal-map (kbd "<left>")  'backward-char)
(define-key uevil-normal-map (kbd "<down>")  'uevil-forward-line)
(define-key uevil-normal-map (kbd "<up>")    'uevil-backward-line)
;; Deletion
(define-key uevil-normal-map "x"  'uevil-suppr)
(define-key uevil-normal-map "X"  'uevil-suppr-before)
(define-key uevil-normal-map "dd" 'uevil-delete-line)

;; Insert state
(define-key uevil-insert-map (kbd "ESC")     'uevil-normal-state)
(define-key uevil-insert-map (kbd "<right>") 'uevil-forward-char)
(define-key uevil-insert-map (kbd "<left>")  'uevil-backward-char)
(define-key uevil-insert-map (kbd "<down>")  'uevil-forward-line)
(define-key uevil-insert-map (kbd "<up>")    'uevil-backward-line)

;; Visual state
(define-key uevil-visual-map (kbd "ESC") 'uevil-normal-state)

;;; Main function
(define-minor-mode uevil-mode
  "A minor mode to provide vi-like keybindings."
  :lighter uevil
  (uevil-normal-state))

(provide 'uevil-mode)
;;; uevil.el ends here
