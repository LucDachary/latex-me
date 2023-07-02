Latex Me
===
A command line to bootstrap Latex documents right in the shell. Documents are created from the
templates located in the `templates/` folder.

Below are the supported templates.

| `-class` | `\documentclass[]` | template file |
| --- | --- | --- |
| `article` | `article` | `templates/article.tex` |
| `report` | `report` | `templates/report.tex` |
| `letter`, `scrlttr2`  | `scrlttr2` | `templates/scrlttr2.tex` |
| `presentation`, `beamer` | `beamer` | `templates/beamer.tex` |

# Requirements
Tcl/Expect is required, as well as the `cmdline` Tcl package. On Archlinux you can that the latter
on AUR.
```shell
# Archlinux instructions
sudo pacman -S expect
paru -S tcllib
```

# Installation
Clone this repository; create a symlink to your local binary folder and that's it!
```shell
gh repo clone LucDachary/latex-me
ln -s `pwd`/latex-me/latexme.tcl ~/.local/bin/latexme
```

# Usage examples
```shell
latexme myarticle.tex

# Run xelatex afterwards
latexme -build myarticle.tex

# Overwrite myarticle.tex
latexme -build -ow myarticle.tex

latexme -class report myreport.tex
latexme -build -class letter myletter.tex
```
