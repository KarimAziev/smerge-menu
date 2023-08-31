;;; smerge-menu.el --- Transient menu for smerge-mode -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Karim Aziiev <karim.aziiev@gmail.com>

;; Author: Karim Aziiev <karim.aziiev@gmail.com>
;; URL: https://github.com/KarimAziev/smerge-menu
;; Version: 0.1.0
;; Keywords: vc
;; Package-Requires: ((emacs "28.1"))
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Transient menu for smerge-mode

;;; Code:

(require 'smerge-mode)

;;;###autoload
(defun smerge-menu-save-and-revert ()
  "Save and bury current buffer and then revert magit buffer."
  (interactive)
  (let ((dir default-directory))
    (save-buffer)
    (bury-buffer)
    (require 'magit nil t)
    (when (fboundp 'magit-status-setup-buffer)
      (magit-status-setup-buffer dir))))

;;;###autoload (autoload 'smerge-menu "smerge-menu" nil t)
(transient-define-prefix smerge-menu ()
  "Command dispatcher for smerge."
  :transient-suffix #'transient--do-call
  :transient-non-suffix #'transient--do-exit
  [["SMerge"
    ("n" "Next" smerge-next)
    ("p" "Previous" smerge-prev)]
   ["Keep"
    ("b" smerge-keep-base :description
     (lambda ()
       (if (smerge-check 2)
           "Base"
         (propertize
          "Base"
          'face
          'transient-inapt-suffix))))
    ("u" smerge-keep-upper :description
     (lambda ()
       (if (smerge-check 1) "Upper"
         (propertize "Upper" 'face
                     'transient-inapt-suffix))))
    ("l" smerge-keep-lower :description
     (lambda ()
       (if (smerge-check 3) "Lower"
         (propertize "Lower" 'face
                     'transient-inapt-suffix))))
    ("a" smerge-keep-all :description
     (lambda ()
       (if (smerge-check 1) "All"
         (propertize
          "All" 'face
          'transient-inapt-suffix))))
    ("RET" smerge-keep-current :description
     (lambda ()
       (if
           (ignore-errors
             (and (smerge-check 1)
                  (> (smerge-get-current) 0)))
           "Current"
         (propertize "Current" 'face
                     'transient-inapt-suffix))))]
   ["Diff"
    ("<" smerge-diff-base-upper :description
     (lambda ()
       (if (smerge-check 2) "Base upper"
         (propertize
          "Base upper" 'face
          'transient-inapt-suffix))))
    ("=" smerge-diff-upper-lower :description
     (lambda ()
       (if (smerge-check 1)
           "Upper lower"
         (propertize
          "Upper lower" 'face
          'transient-inapt-suffix))))
    (">" smerge-diff-base-lower :description
     (lambda ()
       (if (smerge-check 2) "Base lower"
         (propertize
          "Base lower" 'face
          'transient-inapt-suffix))))
    ("h" smerge-refine :description
     (lambda ()
       (if (smerge-check 1)
           "Highlight different words of the conflict"
         (propertize
          "Highlight different words of the conflict"
          'face
          'transient-inapt-suffix))))
    ("E" smerge-ediff :description
     (lambda ()
       (if (smerge-check 1) "Ediff" (propertize "Ediff" 'face
                                                'transient-inapt-suffix))))]
   ["Other"
    ("C" smerge-combine-with-next :description
     (lambda ()
       (if (smerge-check 1)
           "Combine current conflict with next"
         (propertize
          "Combine current conflict with next"
          'face
          'transient-inapt-suffix))))
    ("r" smerge-resolve :description
     (lambda ()
       (if (smerge-check 1) "Auto Resolve"
         (propertize
          "Auto Resolve" 'face
          'transient-inapt-suffix))))
    ("A" "Auto Resolve on all" smerge-resolve-all)
    ("D" "Delete current" smerge-kill-current)
    ("z z" "Save and bury buffer"
     smerge-menu-save-and-revert
     :transient nil)]])

(defun smerge-menu-try-smerge ()
  "Conditionally turn on `smerge-mode'."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "^<<<<<<< " nil t)
      (require 'smerge-mode)
      (smerge-mode 1))))


(provide 'smerge-menu)
;;; smerge-menu.el ends here