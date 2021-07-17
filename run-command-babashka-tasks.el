;;; run-command-babashka-tasks.el --- Run babashka tasks from bb.edn files. -*- lexical-binding: t; -*-

;; Copyright (C) 2021 Nils Grunwald <github.com/ngrunwald>
;; Author: Nils Grunwald
;; URL: https://github.com/ngrunwald/emacs-run-command-babashka-tasks
;; Created: 2021
;; Version: 0.1.0
;; Keywords: clojure, babashka, shell

;; This file is NOT part of GNU Emacs.

;; run-command-babashka-tasks.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; run-command-babashka-tasks.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with run-command-babashka-tasks.el.
;; If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides an easy way to launch tasks from bb.edn files.

;;; Code:
(require 'seq)
(require 's)

(defgroup run-command-babashka-tasks nil
  "Easy way to launch shell commands from deps.edn files."
  :prefix "run-command-babashka-tasks-")

(defconst run-command-babashka-tasks-version "0.1.0")

(defun run-command-babashka-get-tasks ()
  (let* ((raw-tasks (shell-command-to-string "bb tasks"))
         (lines (butlast (seq-drop (s-lines raw-tasks) 2))))
    (seq-map (lambda (l) (let* ((kv (s-split-up-to " " l 1))
                                (task-name (first kv))
                                (task-display (second kv))
                                (base (list :command-name task-name
                                            :command-line (format "bb run %s" task-name)
                                            :working-dir default-directory)))
                           (if task-display
                               (seq-concatenate 'list base (list :display (format "%s → %s" task-name task-display)))
                             base)))
             lines)))

(defun run-command-recipe-babashka-task ()
  (when (executable-find "bb")
    (when-let ((bb-dir (locate-dominating-file default-directory "bb.edn")))
      (let ((default-directory bb-dir))
        (run-command-babashka-get-tasks)))))

;;;###autoload
(defun run-command-babashka-tasks-register ()
  "Register recipes fr handling bb.edn files."
  (interactive)
  (with-eval-after-load 'run-command
    (add-to-list 'run-command-recipes 'run-command-recipe-babashka-task)))

(provide 'run-command-babashka-tasks)
;;; run-command-babashka-tasks.el ends here
