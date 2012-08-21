from distutils.core import setup

import UberInstaller.meta as meta

#This is a list of files to install, and where
#(relative to the 'root' dir, where setup.py is)
#You could be more specific.
files = ["../examples/example.json", "../examples/pre_cmds", "../examples/post_cmds"]

setup(
  name = meta.PROJECT,
  version = meta.VERSION,
  description = meta.DESCRIPTION,
  author = meta.AUTHOR,
  author_email = meta.AUTHOR_EMAIL,
  url = meta.URL,

  #Name the folder where your packages live:
  #(If you have other packages (dirs) or modules (py files) then
  #put them into the package directory - they will be found 
  #recursively.)
  packages = ['UberInstaller', 'JsonMinify'],
  #'package' package must contain files (see list above)
  #I called the package 'package' thus cleverly confusing the whole issue...
  #This dict maps the package name =to=> directories
  #It says, package *needs* these files.
  package_data = {'UberInstaller' : files },

  #'runner' is in the root.
  scripts = ["bin/uberinstaller"],

  long_description = meta.LONG_DESCRIPTION
  #
  #This next part it for the Cheese Shop, look a little down the page.
  #classifiers = []     
) 
