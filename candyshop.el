;;; candyshop.el --- Toggle desktop icons in Emacs

;; Copyright (C) 2024 Mikael Konradsson

;; Author: Mikael Konradsson <mikael.konradsson@outlook.com>
;; Version: 1.0
;; Package-Requires: ((emacs "27"))
;; Keywords: convenience, desktop

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a command to toggle desktop icons on and off in Emacs.

;;; Code:

(defgroup candyshop-show-desktop nil
  "Customization group for hide-show-desktop."
  :group 'convenience)

(defcustom candyshop-alpha-values '(100 . 85)
  "Alpha values for toggling frame transparency.
A cons cell where car is the opaque value and cdr is the transparent value."
  :type '(cons (integer :tag "Opaque value")
               (integer :tag "Transparent value"))
  :group 'candyshop-show-desktop)

(defcustom candyshop-animation-steps 10
  "Number of steps for transparency animation."
  :type 'integer
  :group 'candyshop-show-desktop)

(defvar candyshop-window-configuration nil
  "Store window configuration before hiding windows.")

(defvar candyshop-debug nil
  "Enable debug messages when non-nil.")

(defcustom candyshop-mode-line-indicator '(" 🍬" (:eval (if candyshop-mode "ON" "OFF")))
  "Mode line indicator for candyshop-mode."
  :type 'sexp
  :group 'candyshop-show-desktop)

(put 'candyshop-mode-line-indicator 'risky-local-variable t)

(defun candyshop-debug-message (format-string &rest args)
  "Display debug message if debugging is enabled."
  (when candyshop-debug
    (apply #'message (concat "Candyshop: " format-string) args)))

(defun candyshop-save-window-configuration ()
  "Save current window configuration."
  (setq candyshop-window-configuration
        (current-window-configuration)))

(defun candyshop-restore-window-configuration ()
  "Restore saved window configuration."
  (when candyshop-window-configuration
    (set-window-configuration candyshop-window-configuration)))

(defun candyshop-ensure-macos ()
  "Ensure the current system is macOS."
  (unless (eq system-type 'darwin)
    (user-error "This function is only supported on macOS")))

;;;###autoload
(define-minor-mode candyshop-mode
  "Toggle Candyshop mode.
When enabled, desktop icons are hidden and frame transparency is adjusted."
  :init-value nil
  :lighter candyshop-mode-line-indicator
  :global t
  (candyshop-ensure-macos)
  (if candyshop-mode
      (progn
        (candyshop-debug-message "Enabling candyshop-mode")
        (candyshop-save-window-configuration)
        (candyshop-desktop-icons-off)
        (candyshop-animate-transparency
         (car candyshop-alpha-values)
         (cdr candyshop-alpha-values))
        (candyshop-hide-all-windows-except-emacs))
    (progn
      (candyshop-debug-message "Disabling candyshop-mode")
      (candyshop-desktop-icons-on)
      (candyshop-animate-transparency
       (cdr candyshop-alpha-values)
       (car candyshop-alpha-values))
      (candyshop-show-all-windows)
      (candyshop-restore-window-configuration))))

(defun candyshop-desktop-icons-off ()
  "Hide desktop icons."
  (interactive)
  (candyshop-ensure-macos)
  (candyshop-show-desktop nil))

(defun candyshop-desktop-icons-on ()
  "Show desktop icons."
  (interactive)
  (candyshop-ensure-macos)
  (candyshop-show-desktop t))

(defun candyshop-hide-all-windows-except-emacs ()
  "Hide all candyshop application from Emacs."
  (interactive)
  (candyshop-ensure-macos)
  (shell-command "osascript -e 'tell application \"System Events\" to set visible of every process whose name is not \"Emacs\" to false'"))

(defun candyshop-show-all-windows ()
  "Show all candyshop application windows from Emacs."
  (interactive)
  (candyshop-ensure-macos)
  (shell-command "osascript -e 'tell application \"System Events\" to set visible of every process to true'"))

(defun candyshop-show-desktop (isON)
  "Toggle desktop icons on or off."
  (candyshop-ensure-macos)
  (shell-command (format "defaults write com.apple.finder CreateDesktop %s" (if isON "true" "false")))
  (candyshop-desktop-restart-finder))

(defun candyshop-desktop-restart-finder ()
  "Restart Finder."
  (candyshop-ensure-macos)
  (shell-command "killall Finder"))

(defun candy-shop-set-frame-opacity (opacity)
  "Set the frame opacity to OPACITY."
  (set-frame-parameter nil 'alpha opacity))

(defun candyshop-animate-transparency (start-alpha end-alpha)
  "Animate transparency from START-ALPHA to END-ALPHA."
  (let* ((start (if (listp start-alpha) (car start-alpha) start-alpha))
         (end (if (listp end-alpha) (car end-alpha) end-alpha))
         (diff (- end start))
         (step (/ diff candyshop-animation-steps))
         (current start))
    (dotimes (i candyshop-animation-steps)
      (setq current (+ current step))
      (candy-shop-set-frame-opacity current)
      (sit-for 0.02))))

(defun candyshop-toggle-desktop-icon-alpha ()
  "Toggle between opaque and transparent frame states."
  (interactive)
  (let ((current-alpha (frame-parameter nil 'alpha)))
    (if (or (equal current-alpha (car candyshop-alpha-values))
            (equal current-alpha (cdr candyshop-alpha-values))
            (not current-alpha))
        (candy-shop-set-frame-opacity (cdr candyshop-alpha-values))
      (candy-shop-set-frame-opacity (car candyshop-alpha-values)))))

(provide 'candyshop)
;; candyshop.el ends here
