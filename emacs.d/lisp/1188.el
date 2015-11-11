;;; 1188.el --- Public transportation schedule lookup.  -*- lexical-binding: t; -*-

;; Copyright (C) 2015  Miks Kalniņš

;; Author: Miks Kalniņš <mikskalnins@maikumori.com>
;; Keywords: local, convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This looks up public transportation schedule from http://1188.lv

;; TODO:
;;
;;  - Add tests.
;;  - Allow sorting by different columns (especially arrival time).

;;; Code:
(eval-when-compile
  (require 'cl))
(require 'org)
(require 'rx)
(require 'helm)
(require 'subr-x)
(require 'dash)

(defconst 1188--train-url
  "http://www.1188.lv/satiksme/vilcieni/saraksti"
  "URL endpoint for train schedule.")

(defconst 1188--bus-url
  "http://www.1188.lv/satiksme/starppilsetu-autobusi/saraksti"
  "URL endpoint for bus schedule.")

(defconst 1188--schedule-regexp
  (rx-to-string
   '(seq "ScheduleItem"
         (+\? anything)
         "time datetime=\""
         (submatch
          (+\? anything))
         "\""
         (+\? anything)
         "time datetime=\""
         (submatch
          (+\? anything))
         "\""
         (+\? anything)
         "Title\">"
         (submatch
          (+\? anything))
         "</h2"
         (+\? anything)
         "Col-4-s\">"
         (submatch
          (+\? anything))
         "</div>"
         (+\? anything)
         "Col-5-s\">"
         (submatch
          (+\? anything))
         "<span"
         (+\? anything)
         (or
          (seq "Col-6-s\">"
               (submatch
                (any 45))
               "</div>")
          (seq "<span"
               (+\? anything)
               "\"first\">"
               (submatch
                (+\? anything))
               " <"))))
  "Regexp which matches schedule items.  This is generated from PCRE regexp.

Groups:

 1 - depart time
 2 - arrive time
 3 - name
 4 - time en route
 5 - distance (KM)
 6 - set if no price
 7 - price (EUR)

Regexp: https://regex101.com/r/hX7aU1/1")

(defvar 1188-timetables
  (list (list "Bus  "
              1188--bus-url
              "5492086"
              "5495843")
        (list "Train"
              1188--train-url
              "2051548"
              "2051475"))
  "List of timetables to query.
Each list consists of list of config describing timetable:

 - Identifier
   A way to identify specific timetable.
 - URL
   It should be either `1188--bus-url` or `1188--train-url`.
 - Departure ID
   1188.lv ID for the departure location.
 - Arrival ID
   1188.lv ID for the arrival location.")

(defun 1188--perpare-args (args)
  "Prepare GET arguments from ARGS."
  (mapconcat (lambda (arg)
               (concat (url-hexify-string (car arg))
                       "="
                       (url-hexify-string (cdr arg))))
             args
             "&"))

(defun 1188--get-timetable (url from-id to-id date callback)
  "Downloads and parse schedule information from 1188.
URL is the 1188 URL for given timetable.  FROM-ID is the departure
location id.  TO-ID is the arrival location id.  DATE is the date
for which to get the timetables.  It will call the CALLBACK with
list of results one download is done."
  (url-retrieve
   (concat url "?"
           (1188--perpare-args
            `(("fc" . "1")
              ("tc" . "1")
              ("from-id" . ,from-id)
              ("to-id" . ,to-id)
              ("date" . ,date))))
   (function*
    (lambda (_buf)
      (let (results)
        (while(re-search-forward 1188--schedule-regexp nil t 1)
          (setq results (cons (list (match-string 1)
                                    (match-string 2)
                                    (match-string 3)
                                    (match-string 4)
                                    (match-string 5)
                                    (match-string 6)
                                    (match-string 7)) results)))
        (funcall callback results)))) nil t t))

(defun 1188--collect-timetables (timetables date callback)
  "Collect all TIMETABLES at given DATE.
Calls CALLBACK with collected timetables when done."
  (let ((fetching 0)
        (results nil))
    (dolist (table timetables)
(let (identifier)
  (incf fetching)
  (setq identifier (car table))
  (setq table (cdr table))
  (apply '1188--get-timetable
         (nconc
          table
          (list date (lambda (result)
                       (let (id-results)
                         ;; Append identifier to the results.
                         (dolist (r result)
                           (setq id-results (cons (cons identifier r ) id-results)))
                         (setq results (nconc results id-results))
                         (decf fetching)
                         (when (eq fetching 0)
                           (funcall callback results)))))))))))

(defun 1188--format-name (name)
  "Format NAME."
  (let ((formated-name (replace-regexp-in-string
                        (rx bol (zero-or-more (any blank digit))) "" name)))
    (truncate-string-to-width (string-as-multibyte formated-name) 28 nil ?\s "…")))


(defun 1188--format-entry (entry)
  "Make a string out of ENTRY.

ENTRY is a list with the following elements:

 - Depart time
 - Arrive time
 - Name
 - Time en route
 - Distance (KM)
 - Set if no price
 - Price (EUR)"
  ;; TODO: Entry should be a map, that way it would be more
  ;;       self-documenting.
  (let ((changed-entry (list (nth 0 entry) ; Identifier
                             (nth 1 (split-string (nth 1 entry))) ; Depart
                             (nth 1 (split-string (nth 2 entry))) ; Arrive
                             (1188--format-name (nth 3 entry)) ; Name
                             (concat (nth 4 entry) "h")        ; Time
                             (concat (nth 5 entry) " km") ; Distance
                             (if (nth 6 entry) "Unknown Price"
                               (concat (nth 7 entry) " EUR")))))
    (string-as-multibyte
     (string-join changed-entry "  "))))

(defun 1188--sort-by-time (x y)
  "Sort function to sort entries by time.
Return non-nil when entry X should be located before entry Y."
  (let* ((xx (split-string (substring (nth 1 x) 11) ":"))
         (yy (split-string (substring (nth 1 y) 11) ":"))
         (xh (string-to-number
              (nth 0 xx)))
         (xm (string-to-number
              (nth 1 xx)))
         (yh (string-to-number
              (nth 0 yy)))
         (ym (string-to-number
              (nth 1 yy))))
    (cond ((< xh yh) t)
          ((> xh yh) nil)
          ((= xh yh) (< xm ym)))))

(defun 1188--entry-is-current-p (entry)
  "Return true if ENTRY is not in the past."
  (time-less-p (current-time) (date-to-time (nth 1 entry))))

(defun helm-1188-lookup-transport (show-date-picker)
  "Lookup transport.
If SHOW-DATE-PICKER is set (universal argument) then show date
picker."
  (interactive "P")
  (let (buf date is-today)
    (setq date (if show-date-picker
                   (org-read-date)
                 (format-time-string "%F")))
    (setq is-today (string= date (format-time-string "%F") ))
    (setq buf (buffer-name))
    (1188--collect-timetables
     1188-timetables
     date
     (lambda (results)
       (let (pick)
         (setq pick (helm
                     :sources
                     (helm-build-in-buffer-source
                         "Transport"
                       :data (mapcar
                              '1188--format-entry
                              (sort
                               ;; Note: The parsed output from the
                               ;; website always has today's date,
                               ;; even when looking up schedules in
                               ;; future. Time is correct.
                               (if is-today
                                   (-filter '1188--entry-is-current-p results)
                                 results)
                               '1188--sort-by-time)))
                     :buffer "*helm 1188*"))
         (when pick
           (with-current-buffer buf
             (insert pick))))))))

(provide (intern "1188"))
;;; 1188.el ends here
