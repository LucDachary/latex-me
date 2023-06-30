Latex Me
===
A command line to bootstrap Latex documents right in the shell.

TODO:
* add `scrlttr2` class support;
* add `report` class support;
* add `beamer` class support;
* add an option to build and have a building directory;

# Installation
Clone this repository; create a symlink to your local binary folder and that's it!
```shell
gh repo clone LucDachary/latex-me
ln -s `pwd`/latex-me/latexme.tcl ~/.local/bin/latexme
```
# Usage
```shell
$ latexme article myarticle.tex
```

# Requirements
Tcl/Expect is required, as well as the `cmdline` Tcl package. On Archlinux you can that the latter
on AUR.
```shell
# Archlinux instructions
sudo pacman -S expect
paru -S tcllib
```
