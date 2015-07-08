#!/usr/bin/sbcl --script
;; Ahungry Blog - Free as in Freedom blogging software in Common Lisp
;; Copyright (C) 2013 Matthew Carter
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Affero General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Affero General Public License for more details.
;;
;; You should have received a copy of the GNU Affero General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(load "~/quicklisp/setup.lisp")
(mapc (lambda (f) (ql:quickload f :verbose nil))
      '(:cl-who :cl-ppcre :glyphs))

(defpackage :ahungry-blog
  (:use :cl :cl-ppcre :cl-who :glyphs))

(in-package :ahungry-blog)

(in-readtable glyphs:syntax)

;; Page defaults (set for when you hate using options)
(defparameter author "Ahungry Blog")
(defparameter title "Ahungry Blog")
(defparameter date "Sometime in the past")
(defparameter meta-desc "Ahungry Blog")
(defparameter meta-keys "Ahungry Blog, Ahungry, Ahungry dot com")
(defparameter *html-out* nil)
(defparameter *index-file-html* "<a href='/'>to main site...</a><a href='https://github.com/ahungry/ahungry-blog'>git the source</a><ul>")

(ƒ get-date-from-name ~"(\\d{4})-(\\d{2})-(\\d{2}).*"~ → |"\\1-\\2-\\3"|)
(ƒ get-setf-options  ~"(?i)(?s).*?(\\(setf.*?\\)).*"~ → |"\\1"|)
(ƒ get-html  ~"(?i)(?s)(.*?)\\(setf.*?\\)(.*)"~ → |"\\1\\2"|)

(defun markup-file (file-name)
  "Parse options out of a file as well as HTML"
  (let ((html ""))
    (with-open-file (stream file-name)
      (loop for line = (read-line stream nil 'eof)
           until (eq line 'eof)
           do (setf html (format nil "~a~%~a" html line)))
      (eval (read-from-string (get-setf-options html))) ;; Set the options
      (setf html (get-html html)))))

(defun html-output (file-name)
  "Combine the parsed out options with a template from cl-who"
  (let ((html (markup-file file-name)))
    (with-html-output-to-string (*html-out* nil :prologue t)
      (setf (html-mode) :html5)
      (htm
       *prologue*
       (:html
        (:head (:title (esc title))
               (:meta :name "description" :value meta-desc)
               (:meta :name "keywords" :value meta-keys)
               (:meta :name "author" :value author)
               (:meta :charset "utf-8")
               (:script :src "ahungry-blog.js" :type "text/javascript")
               (:link :href "ahungry-blog.css" :rel "stylesheet" :type "text/css"))
        (:body
         (:img :src "logo.png")
         (:a :href "index.html" "&laquo; Back to article list")
         (:h1 (esc title))
         (str html)))))))

(defun write-to-file (file-name)
  (let ((output-file-name (concatenate 'string
                                       (cl-ppcre:regex-replace-all
                                        "^(.*)_posts.*\/(.*)$"
                                        file-name "\\1\\2"))))
    (with-open-file (stream output-file-name
                            :direction :output
                            :if-exists :supersede
                            :if-does-not-exist :create)
      (format stream "~a" (html-output file-name)))))

(defun create-index-file ()
  (let* ((out-path (namestring (merge-pathnames "articles/" *default-pathname-defaults*)))
         (out-file (concatenate 'string out-path "index.html")))
    (with-open-file (stream out-file
                            :direction :output
                            :if-exists :supersede
                            :if-does-not-exist :create)
      (let ((html *index-file-html*))
        (with-html-output (stream nil :prologue t)
          (setf (html-mode) :html5)
          (htm
           *prologue*
           (:html
            (:head (:title (esc title))
                   (:meta :name "description" :value meta-desc)
                   (:meta :name "keywords" :value meta-keys)
                   (:meta :name "author" :value author)
                   (:script :src "ahungry-blog.js" :type "text/javascript")
                   (:link :href "ahungry-blog.css" :rel "stylesheet" :type "text/css"))
            (:body
             (:img :src "logo.png")
             (str html) "</ul>"))))))))

(defun main (file-name)
  "Generate the relevant files, prepare an index file"
  (when (not (stringp (type-of file-name)))
    (setf file-name (namestring file-name)))
  (format t "Creating new file from [~a]...~%" file-name)
  (write-to-file file-name)
  (let* ((base-file-name (cl-ppcre:regex-replace-all ".*\/_posts\/(.*)" file-name "\\1"))
         (file-date (get-date-from-name base-file-name)))
    (setf *index-file-html* (format nil "~a~%<li><a href='~a'>~a</a>[~a]</li>"
                                    *index-file-html*
                                    base-file-name
                                    title
                                    file-date))))

;; If args are passed in, we will convert the individual files
;; Otherwise just loop over all files in the _path
(let ((args sb-ext:*posix-argv*))
  (if (> (length args) 1)
      (progn (pop args) ;; Get rid of the script name
             (mapcar #'main args))
      (mapc #'main (nreverse (directory
                              (merge-pathnames
                               "articles/_posts/*.*"
                               *default-pathname-defaults*)))))
  (create-index-file)) ;; Run main on each file
