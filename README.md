ahungry-blog
============

Minimal blogging software written in Common Lisp to be used
with Emacs' org-mode and org-publish as a way to create blog
entries.

See the sample dot-emacs file (should go in your ~/.emacs) to set up
org-mode up for this type of usage (or copy dot-emacs into a .el file
and #'require it in your emacs).

## Usage

To start a new blog post:
```lisp
M-x ahungry-new-blog
```

You'll be prompted to create a title, I suggest using the following
format for the best functionality/usage of this tool:

```lisp
YYYY-mm-dd-Some-text-separated-by-dashes
```

After creating a file, publish your entries (customize the git information
to point to your own bare repo to push changes into) and run:

```lisp
M-x ahungry-publish
```

This should create the articles, index page etc., and push to your
bare repository (which you will hopefully have something pulling from
to deploy the blog code on the fly).

For more details, see the blog post about the software:

http://ahungry.com/blog/2013-04-01-blogging-with-org-mode.html
