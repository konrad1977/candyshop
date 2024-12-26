;;; hide-show-desktop.el --- Toggle desktop icons in Emacs

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

;;;###autoload
(define-minor-mode candyshop-mode
  "Toggle Candyshop mode.
When enabled, desktop icons are hidden and frame transparency is adjusted."
  :init-value nil
  :lighter " 🍬"
  :global t
  (if candyshop-mode
      (progn
        (candyshop-desktop-icons-off)
        (candy-shop-set-frame-opacity (cdr candyshop-alpha-values))
        (candyshop-hide-all-windows-except-emacs))
    (progn
      (candyshop-desktop-icons-on)
      (candy-shop-set-frame-opacity (car candyshop-alpha-values))
      (candyshop-show-all-windows))))

(defun candyshop-desktop-icons-off ()
  "Hide desktop icons."
  (interactive)
  (when (string-equal system-type 'darwin)
    (candyshop-show-desktop nil)))

(defun candyshop-desktop-icons-on ()
  "Show desktop icons."
  (interactive)
  (when (string-equal system-type 'darwin)
    (candyshop-show-desktop t)))

(defun candyshop-hide-all-windows-except-emacs ()
  "Hide all candyshop application from Emacs."
  (interactive)
  (shell-command "osascript -e 'tell application \"System Events\" to set visible of every process whose name is not \"Emacs\" to false'"))

(defun candyshop-show-all-windows ()
  "Show all candyshop application windows from Emacs."
  (interactive)
  (shell-command "osascript -e 'tell application \"System Events\" to set visible of every process to true'"))

(defun candyshop-show-desktop (isON)
  "Toggle desktop icons on or off."
  (when (string-equal system-type 'darwin)
    (shell-command (format "defaults write com.apple.finder CreateDesktop %s" (if isON "true" "false")))
    (candyshop-desktop-restart-finder)))

(defun candyshop-desktop-restart-finder ()
  "Restart Finder."
  (when (string-equal system-type 'darwin)
    (shell-command "killall Finder")))

(defun candy-shop-set-frame-opacity (opacity)
  "Set the frame opacity to OPACITY."
  (set-frame-parameter nil 'alpha opacity))

(defun candyshop-toggle-desktop-icon-alpha ()
  "Toggle between opaque and transparent frame states."
  (interactive)
  (let ((current-alpha (frame-parameter nil 'alpha)))
    (if (or (equal current-alpha (car candyshop-alpha-values))
            (equal current-alpha 100)
            (not current-alpha))
        (candy-shop-set-frame-opacity (cdr candyshop-alpha-values))
      (candy-shop-set-frame-opacity (car candyshop-alpha-values)))))

(provide 'candyshop)
;; candyshop.el ends here
