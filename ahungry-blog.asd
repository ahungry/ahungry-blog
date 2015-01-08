(asdf:defsystem "ahungry-blog"
  :description "Blog automation via lisp, emacs and git"
  :version "0.0.2"
  :author "Matthew Carter <m@ahungry.com>"
  :license "LGPLv3"
  :components ((:file "packages")
	       (:file "ahungry-blog" :depends-on ("packages"))))
